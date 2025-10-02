import common/grid2d
import day14/day14.{type Input, type Robot, Robot}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

fn parse_int(text: String) -> Result(Int, String) {
  int.parse(text)
  |> result.replace_error("Could not parse `" <> text <> "` as an integer")
}

pub fn parse_line(line: String) -> Result(Robot, String) {
  let trimmed = string.trim(line)
  let assert Ok(pattern) =
    regexp.from_string("p=(-?\\d+),(-?\\d+)\\s+v=(-?\\d+),(-?\\d+)")

  case regexp.scan(with: pattern, content: trimmed) {
    [match, ..] ->
      case match.submatches {
        [Some(col_str), Some(row_str), Some(dx_str), Some(dy_str)] -> {
          use col <- result.try(parse_int(col_str))
          use row <- result.try(parse_int(row_str))
          use dx <- result.try(parse_int(dx_str))
          use dy <- result.try(parse_int(dy_str))

          let position = grid2d.Index2D(row, col)
          let velocity = grid2d.Offset2D(dy, dx)

          Ok(Robot(position: position, velocity: velocity))
        }

        _ -> Error("Regex failed for line: " <> trimmed)
      }

    [] -> Error("Line did not match robot regex: " <> trimmed)
  }
}

pub fn read_input(input_path) -> Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file!" })

  use contents <- result.try(read_result)
  contents
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_line)
  |> result.all
}

pub fn main() {
  day14.example1_path |> read_input |> echo
}
