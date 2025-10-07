import day17/day17 as d17
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

/// Parse a decimal string into an `Int`, returning a friendly error message on
/// failure instead of crashing.
fn parse_int(text: String) -> Result(Int, String) {
  case int.parse(text) {
    Ok(value) -> Ok(value)
    Error(_) -> Error("Could not parse an Int from: " <> text)
  }
}

/// Trim the surrounding whitespace and drop any blank lines left in between.
fn non_blank_lines(section: String) -> List(String) {
  section
  |> string.trim
  |> string.split(on: "\n")
  |> list.filter(fn(line) { string.length(string.trim(line)) > 0 })
}

/// Decode the three register initialisers from the header of the input file.
fn parse_registers(section: String) -> Result(d17.Registers, String) {
  case non_blank_lines(section) {
    [a_line, b_line, c_line] -> {
      use a <- result.try(parse_register_line(a_line, "A"))
      use b <- result.try(parse_register_line(b_line, "B"))
      use c <- result.try(parse_register_line(c_line, "C"))
      Ok(d17.Registers(a: a, b: b, c: c))
    }
    _ -> Error("Expected register definitions for A, B, and C")
  }
}

/// Parse a single register line, ensuring the expected label is present.
fn parse_register_line(
  line: String,
  expected_label: String,
) -> Result(Int, String) {
  let assert Ok(pattern) = regexp.from_string("^Register ([ABC]): (\\d+)$")
  let trimmed = string.trim(line)
  let parse_error = "Could not parse register line: " <> trimmed

  use first_match <- result.try(
    case regexp.scan(with: pattern, content: trimmed) {
      [match, ..] -> Ok(match)
      _ -> Error(parse_error)
    },
  )

  case first_match.submatches {
    [Some(label), Some(value)] if label == expected_label -> parse_int(value)
    _ -> Error(parse_error)
  }
}

/// Split the "Program" line into raw opcode/operand integers.
fn parse_program(section: String) -> Result(List(Int), String) {
  case non_blank_lines(section) {
    [line] -> {
      let assert Ok(pattern) = regexp.from_string("^Program: (\\d+(?:,\\d+)*)$")
      let trimmed_line = string.trim(line)
      let parse_error = "Could not parse program line: " <> trimmed_line

      use first_match <- result.try(
        case regexp.scan(with: pattern, content: trimmed_line) {
          [match, ..] -> Ok(match)
          _ -> Error(parse_error)
        },
      )

      case first_match.submatches {
        [Some(values_part)] ->
          values_part
          |> string.split(on: ",")
          |> list.try_map(fn(text) { string.trim(text) |> parse_int })
        _ -> Error(parse_error)
      }
    }
    _ -> Error("Expected a single program line after the registers")
  }
}

/// Fully parse the puzzle input into an initial machine state and the raw
/// instruction list.
fn parse_contents(
  contents: String,
) -> Result(#(d17.ProgramState, List(Int)), String) {
  let sections =
    contents
    |> string.split(on: "\n\n")
    |> list.filter(fn(section) { string.length(string.trim(section)) > 0 })

  case sections {
    [register_section, program_section] -> {
      use registers <- result.try(parse_registers(register_section))
      use raw_program <- result.try(parse_program(program_section))
      Ok(#(d17.ProgramState(registers, 0, []), raw_program))
    }
    _ ->
      Error("Expected register and program sections separated by a blank line")
  }
}

/// Read the text file and return the parsed representation of the initial
/// state of the program and the list of instructions.
pub fn read_input(input_path) -> d17.Input {
  simplifile.read(input_path)
  |> result.map(string.trim)
  |> result.replace_error("Could not read file at " <> input_path)
  |> result.try(parse_contents)
}

pub fn main() {
  d17.example1_path |> read_input |> echo
}
