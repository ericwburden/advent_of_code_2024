import day04/day04.{type Char, type Index2D, type Input, A, Index2D, M, S, X}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Convert a character into its corresponding [Char] variant.
pub fn string_to_char(s: String) -> Result(Char, String) {
  case s {
    "X" -> Ok(X)
    "M" -> Ok(M)
    "A" -> Ok(A)
    "S" -> Ok(S)
    _ -> Error("Cannot parse a Char from '" <> s <> "'!")
  }
}

/// Parses a line from the input file into a list of key/value pairs,
/// where the keys are the 2D index of the character and the value is the 
/// character at that index.
fn row_to_chargrid_entries(
  str: String,
  row: Int,
) -> Result(List(#(Index2D, Char)), String) {
  string.to_graphemes(str)
  |> list.index_map(fn(g, col) {
    use char <- result.map(string_to_char(g))
    let idx = Index2D(row, col)
    #(idx, char)
  })
  |> result.all
}

/// Parse the input file into a [Dict] representing a grid of characters.
pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.map(string.trim)
    |> result.replace_error(
      "Could not read from file at '" <> input_path <> "'!",
    )
  use contents <- result.try(read_file_result)

  contents
  |> string.split("\n")
  |> list.index_map(row_to_chargrid_entries)
  |> result.all
  |> result.map(list.flatten)
  |> result.map(dict.from_list)
}
