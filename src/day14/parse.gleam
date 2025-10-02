import day14/day14.{type Input}
import gleam/string
import simplifile

pub fn read_input(input_path) -> Input {
  let assert Ok(contents) = simplifile.read(input_path)
  string.split(contents, on: "\n")
}
