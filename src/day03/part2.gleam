import day03/day03.{type Input, type Output}
import day03/part1.{parse_with_err_msg}
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

type AccumulatorState {
  Keeping(Int)
  Dropping(Int)
}

fn extract_instructions(line: String) -> Result(List(Instruction), String) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  regexp.scan(with: re, content: line)
  |> list.map(parse_match)
  |> result.all
}

fn parse_match(match: regexp.Match) -> Result(Instruction, String) {
  case match.content {
    "do()" -> Ok(Do)
    "don't()" -> Ok(Dont)
    "mul" <> _ ->
      case match.submatches {
        [Some(left_str), Some(right_str), ..] -> {
          use left <- result.try(parse_with_err_msg(left_str))
          use right <- result.map(parse_with_err_msg(right_str))
          Mul(left, right)
        }
        _ ->
          Error("Not enough submatches in " <> string.inspect(match.submatches))
      }
    _ -> Error("No instruction for " <> string.inspect(match))
  }
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let parse_instructions_result =
    input
    |> list.map(extract_instructions)
    |> result.all
    |> result.map(list.flatten)
  use instructions <- result.map(parse_instructions_result)
  let accumulator =
    instructions
    |> list.fold(Keeping(0), fn(acc, instr) {
      let acc_value = case acc {
        Keeping(n) -> n
        Dropping(n) -> n
      }
      case instr {
        Do -> Keeping(acc_value)
        Dont -> Dropping(acc_value)
        Mul(l, r) ->
          case acc {
            Keeping(v) -> Keeping(v + { l * r })
            Dropping(v) -> Dropping(v)
          }
      }
    })
  case accumulator {
    Keeping(n) -> n
    Dropping(n) -> n
  }
}
