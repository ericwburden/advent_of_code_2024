import day13/day13
import gleam/int
import gleam/io
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

fn parse_button(line: String) -> Result(day13.Button, String) {
  let assert Ok(pattern) =
    regexp.from_string("Button ([AB]): X\\+(\\d+), Y\\+(\\d+)")

  case regexp.scan(with: pattern, content: line) {
    [match, ..] ->
      case match.submatches {
        [Some(_label), Some(dx_text), Some(dy_text)] -> {
          use dx <- result.try(parse_int(dx_text))
          use dy <- result.try(parse_int(dy_text))

          Ok(day13.Button(dx: dx, dy: dy))
        }

        _ -> Error("Malformed button line: " <> line)
      }

    [] -> Error("Button regex did not match line: " <> line)
  }
}

fn parse_prize(line: String) -> Result(day13.Prize, String) {
  let assert Ok(pattern) = regexp.from_string("Prize: X=(\\d+), Y=(\\d+)")

  case regexp.scan(with: pattern, content: line) {
    [match, ..] ->
      case match.submatches {
        [Some(x_text), Some(y_text)] -> {
          use x <- result.try(parse_int(x_text))
          use y <- result.try(parse_int(y_text))

          Ok(day13.Prize(x: x, y: y))
        }

        _ -> Error("Malformed prize line: " <> line)
      }

    [] -> Error("Prize regex did not match line: " <> line)
  }
}

fn parse_machine_chunk(chunk: String) -> Result(day13.Machine, String) {
  case chunk |> string.trim |> string.split("\n") {
    [button_a_line, button_b_line, prize_line] -> {
      use button_a <- result.try(parse_button(button_a_line))
      use button_b <- result.try(parse_button(button_b_line))
      use prize <- result.try(parse_prize(prize_line))

      Ok(day13.Machine(a: button_a, b: button_b, prize: prize))
    }

    _ -> Error("Expected three lines per machine chunk! Got: " <> chunk)
  }
}

pub fn read_input(input_path) -> day13.Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file!" })

  use contents <- result.try(read_result)
  contents
  |> string.trim
  |> string.split("\n\n")
  |> list.map(parse_machine_chunk)
  |> result.all
}

pub fn main() {
  day13.example1_path |> read_input |> io.debug
}
