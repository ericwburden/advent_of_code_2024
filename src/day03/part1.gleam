import day03/day03.{type Input, type Output}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

pub fn parse_with_err_msg(s: String) -> Result(Int, String) {
  int.parse(s)
  |> result.replace_error("Could not parse " <> s <> " as an integer!")
}

fn parse_match(match: regexp.Match) -> Result(Int, String) {
  case match.submatches {
    [Some(left_str), Some(right_str), ..] -> {
      use left <- result.try(parse_with_err_msg(left_str))
      use right <- result.map(parse_with_err_msg(right_str))
      left * right
    }
    _ -> Error("Not enough submatches in " <> string.inspect(match.submatches))
  }
}

fn extract_mul_instructions(line: String) -> Result(List(Int), String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(with: re, content: line) |> list.map(parse_match) |> result.all
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let parse_instructions_result =
    input
    |> list.map(extract_mul_instructions)
    |> result.all
    |> result.map(list.flatten)
  use instructions <- result.map(parse_instructions_result)
  instructions |> int.sum
}
