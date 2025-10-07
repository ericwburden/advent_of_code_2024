import day17/day17 as d17
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import simplifile

fn parse_int(text: String) -> Int {
  let assert Ok(value) = int.parse(text)
  value
}

fn parse_registers(section: String) -> d17.Registers {
  let assert [a_line, b_line, c_line] =
    section
    |> string.trim
    |> string.split(on: "\n")
    |> list.filter(fn(line) { string.length(string.trim(line)) > 0 })

  d17.Registers(
    a: parse_register_line(a_line, "A"),
    b: parse_register_line(b_line, "B"),
    c: parse_register_line(c_line, "C"),
  )
}

fn parse_register_line(line: String, expected_label: String) -> Int {
  let pattern = register_pattern()
  let assert [match, ..] =
    regexp.scan(with: pattern, content: string.trim(line))
  let assert [Some(label), Some(value_text)] = match.submatches
  let assert True = label == expected_label
  parse_int(value_text)
}

fn register_pattern() -> regexp.Regexp {
  let assert Ok(pattern) = regexp.from_string("^Register ([ABC]): (\\d+)$")
  pattern
}

fn parse_program(section: String) -> List(Int) {
  let assert [line] =
    section
    |> string.trim
    |> string.split(on: "\n")
    |> list.filter(fn(line) { string.length(string.trim(line)) > 0 })

  let pattern = program_pattern()
  let assert [match, ..] =
    regexp.scan(with: pattern, content: string.trim(line))
  let assert [Some(values_part)] = match.submatches

  let numbers =
    values_part
    |> string.split(on: ",")
    |> list.map(fn(text) { parse_int(string.trim(text)) })

  numbers
}

fn program_pattern() -> regexp.Regexp {
  let assert Ok(pattern) = regexp.from_string("^Program: (\\d+(?:,\\d+)*)$")
  pattern
}

fn parse_contents(contents: String) -> #(d17.ProgramState, List(Int)) {
  let assert [register_section, program_section] =
    contents
    |> string.trim
    |> string.split(on: "\n\n")

  let registers = parse_registers(register_section)
  let raw_program = parse_program(program_section)

  #(
    d17.ProgramState(
      registers: registers,
      instruction_pointer: 0,
      output: [],
    ),
    raw_program,
  )
}

pub fn read_input(input_path) -> d17.Input {
  let assert Ok(contents) = simplifile.read(input_path)
  Ok(parse_contents(contents))
}

pub fn main() {
  d17.example1_path |> read_input |> echo
}
