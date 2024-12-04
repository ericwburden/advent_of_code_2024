import day03/day03.{type Input, type Output}
import day03/part1.{parse_with_err_msg}
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

/// Now we have more than one kind of instruction! A [Do] indicates that we should
/// keep the results of the following [Mul] instructions, and a [Dont] indicates
/// we should ignore the following [Mul] instructions.
type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

/// This will let our accumulator know whether it should count the results of [Mul] 
/// instructions it receives.
type AccumulatorState {
  Keeping
  Dropping
}

/// Basically just a wrapper for a [#(Int, AccumulatorState)]. We'll use this to sum
/// the products of the [Mul] instructions we aren't supposed to ignore.
type Accumulator {
  Accumulator(n: Int, state: AccumulatorState)
}

/// This time, there are three different instructions to extract from the input, so
/// our regular expression is a bit more complicated, but not by much.
fn extract_instructions(line: String) -> Result(List(Instruction), String) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  regexp.scan(with: re, content: line)
  |> list.map(parse_match)
  |> result.all
}

/// And, with multiple instruciton variants, we again need to add a bit more complexity
/// to our parsing function to account for those other two instruction variants.
fn parse_match(match: regexp.Match) -> Result(Instruction, String) {
  case match.content {
    "do()" -> Ok(Do)
    "don't()" -> Ok(Dont)
    "mul" <> _ ->
      case match.submatches {
        [Some(left_str), Some(right_str)] -> {
          use left <- result.try(parse_with_err_msg(left_str))
          use right <- result.map(parse_with_err_msg(right_str))
          Mul(left, right)
        }
        _ -> Error("Not enough submatches in " <> string.inspect(match))
      }
    _ -> Error("No instruction for " <> string.inspect(match))
  }
}

/// For part 2, we have extra instructions that tell us whether to include
/// or exclude the result of [Mul] instructions in our final total. To that end,
/// I'm using a custom accumulator that can be switched on/off when encountering
/// the [Do]/[Dont] instructions. Other than that, it's pretty much the same.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let parse_instructions_result =
    input
    |> list.map(extract_instructions)
    |> result.all
    |> result.map(list.flatten)
  use instructions <- result.map(parse_instructions_result)

  // Fold using our custom accumulator
  let accumulator =
    list.fold(instructions, Accumulator(0, Keeping), fn(acc, instr) {
      case instr {
        // Turn the accumulator on
        Do -> Accumulator(acc.n, Keeping)

        // Turn the accumulator off
        Dont -> Accumulator(acc.n, Dropping)

        // Add the product of the [Mul] to the total if the accmulator is on,
        // otherwise just skip it.
        Mul(l, r) ->
          case acc.state {
            Keeping -> Accumulator(acc.n + { l * r }, acc.state)
            Dropping -> acc
          }
      }
    })
  accumulator.n
}
