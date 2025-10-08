import day19/day19.{type Input}
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_contents(contents: String) -> Result(#(List(String), List(String)), String) {
  let trimmed_contents = string.trim(contents)

  case string.split(trimmed_contents, on: "\n") {
    [] -> Error("Input file was empty")
    [first_line, ..rest] -> {
      let patterns =
        first_line
        |> string.trim
        |> string.split(on: ",")
        |> list.map(string.trim)
        |> list.filter(fn(pattern) { string.length(pattern) > 0 })

      let designs =
        rest
        |> list.map(string.trim)
        |> list.filter(fn(line) { string.length(line) > 0 })

      Ok(#(patterns, designs))
    }
  }
}

pub fn read_input(input_path) -> Input {
  simplifile.read(input_path)
  |> result.replace_error("Could not read file at " <> input_path)
  |> result.try(parse_contents)
}

pub fn main() {
  day19.example1_path |> read_input |> echo
}
