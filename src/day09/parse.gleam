import day09/day09.{type Input}
import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn string_to_digits(s: String) -> Result(List(Int), String) {
  string.to_graphemes(s)
  |> list.try_map(fn(ch) {
    case int.parse(ch) {
      Ok(n) -> Ok(n)
      Error(_) -> Error("Invalid digit: " <> ch)
    }
  })
}

pub fn read_input(input_path) -> Input {
  let assert Ok(contents) = simplifile.read(input_path)
  contents |> string.trim |> string_to_digits
}
