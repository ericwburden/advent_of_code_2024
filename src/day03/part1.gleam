import day03/day03.{type Input, type Output}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

/// Handy helper function for providing a slightly better error message if 
/// we fail to parse a String into an Int.
pub fn parse_with_err_msg(s: String) -> Result(Int, String) {
  int.parse(s)
  |> result.replace_error("Could not parse " <> s <> " as an integer!")
}

/// Parses a regular expression [Match] for a multiplication operation into the 
/// result of that operation. Since I'm using regular expressions to extract the 
/// "mul(x,y)" instructions from the string, this function takes one of those
/// matches and returns `x * y`.
fn parse_match(match: regexp.Match) -> Result(Int, String) {
  case match.submatches {
    // We expect to have submatches like [Some("1"), Some("2")] from parsing "mul(1,2)"
    // The rest is just parsing those number strings as integers and returning the
    // product.
    [Some(left_str), Some(right_str)] -> {
      use left <- result.try(parse_with_err_msg(left_str))
      use right <- result.map(parse_with_err_msg(right_str))
      left * right
    }
    // Any other submatch means there's something wrong with our regular expression
    // and we need to check the string that didn't match.
    _ -> Error("Not enough submatches in " <> string.inspect(match.submatches))
  }
}

/// This bit just extracts the one kind of instruction from a line of our input
/// file. I'm using capture groups for the two numbers to help with parsing
/// the [Match].
fn extract_mul_instructions(line: String) -> Result(List(Int), String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(with: re, content: line) |> list.map(parse_match) |> result.all
}

/// For today's part 1, we need to extract all the "mul(x,y)" instructions from the
/// input text, calculate the product of the two numbers, and return the total of
/// those products
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let parse_instructions_result =
    input
    |> list.map(extract_mul_instructions)
    |> result.all
    |> result.map(list.flatten)
  use products <- result.map(parse_instructions_result)
  int.sum(products)
}
