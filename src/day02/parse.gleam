import day02/day02.{type Input, type Report}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_with_err_msg(s: String) -> Result(Int, String) {
  int.parse(s)
  |> result.replace_error("Could not parse a number from " <> s <> "!")
}

fn parse_line(line: String) -> Result(Report, String) {
  line
  |> string.split(on: " ")
  |> list.map(parse_with_err_msg)
  |> result.all
}

pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.replace_error("Could not read file at " <> input_path)
    |> result.map(string.trim)
  use contents <- result.try(read_file_result)
  string.split(contents, on: "\n") |> list.map(parse_line) |> result.all
}