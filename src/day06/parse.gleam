import day04/day04
import day06/day06.{type Input}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Parses a single character from the input text into one of the two types
/// of grid spaces. We're ignoring the '^' representing the guard on the map
/// since that guard is technically standing on an [Empty] space. We'll
/// identify the [Guard] specifically later on.
fn parse_space(str: String) -> Result(day06.Space, Nil) {
  case str {
    "#" -> Ok(day06.Obstacle)
    "^" -> Ok(day06.Empty)
    "." -> Ok(day06.Empty)
    _ -> Error(Nil)
  }
}

/// Parses an entire row from the input text into a list of indices and the [Space]
/// at that index.
fn parse_row(row: Int, str: String) -> List(#(day04.Index2D, day06.Space)) {
  string.to_graphemes(str)
  |> list.index_map(fn(char, col) { #(char, col) })
  |> list.filter_map(fn(char_and_col) {
    let #(char, col) = char_and_col
    parse_space(char) |> result.map(fn(s) { #(day04.Index2D(row, col), s) })
  })
}

/// Read the input text and convert it into an [Input] data type.
pub fn read_input(input_path) -> Input {
  // Read the file and store the results as a list of strings, where each
  // string represents a line from the input text.
  let read_file_result =
    simplifile.read(input_path)
    |> result.map(string.trim)
    |> result.replace_error("Could not read file at '" <> input_path <> "'!")
  use contents <- result.try(read_file_result)

  // Convert the lines from the input into a [PatrolMap], identifying the
  // index and identity of each [Space].
  let patrol_map =
    string.split(contents, "\n")
    |> list.index_map(fn(line, row) { parse_row(row, line) })
    |> list.flatten
    |> dict.from_list

  // Now let's find that guard! We search over each character in each line
  // and take the '^' as the index where the [Guard] is found.
  let guard_result =
    string.split(contents, "\n")
    |> list.index_map(fn(line, row) {
      string.to_graphemes(line)
      |> list.index_map(fn(char, col) { #(row, col, char) })
    })
    |> list.flatten
    |> list.find_map(fn(row_col_char) {
      case row_col_char {
        #(row, col, "^") ->
          Ok(day06.Guard(day04.Index2D(row, col), day06.North))
        _ -> Error(Nil)
      }
    })
    |> result.replace_error("Could not find the guard!")

  use guard <- result.map(guard_result)
  #(guard, patrol_map)
}
