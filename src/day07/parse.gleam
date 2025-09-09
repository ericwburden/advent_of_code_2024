import day07/day07.{type Input}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Given a string composed of numbers separated by spaces, parse that string
/// into a list of integers.
pub fn parse_space_separated_int_list(
  input: String,
) -> Result(List(Int), String) {
  // Clean up the string, split on spaces, and drop any empty strings
  let tokens =
    input
    |> string.trim
    |> string.split(" ")
    |> list.filter(fn(s) { s != "" })

  // Accumulate the parsed integers into a list. Short-circuits if any string
  // is found that cannot be parsed into an integer, returning an error
  // message in that case.
  list.fold(tokens, Ok([]), fn(acc, token) {
    use parsed <- result.try(acc)
    use n <- result.try(
      int.parse(token)
      |> result.map_error(fn(_) {
        "Could not parse: " <> token <> " in list [" <> input <> "]"
      }),
    )

    Ok([n, ..parsed])
  })
  |> result.map(list.reverse)
}

/// Parse an entire line from the input, representing a single set of equation
/// parts. Includes the target value and the numbers that can potentially
/// be combined to yield that target value.
pub fn parse_line(line: String) -> Result(day07.EquationParts, String) {
  // Attempt to split on the colon, yielding two parts. If anything else
  // results, return an error messaage.
  case string.split(line, ":") {
    // If there are two parts, parse the left part into an integer and the
    // right part into a list of integers (assumes space-separated). Return
    // the appropriate error message if either part fails.
    [test_str, comps_str] ->
      case int.parse(string.trim(test_str)) {
        Ok(test_val) -> {
          use components <- result.try(parse_space_separated_int_list(comps_str))
          Ok(day07.EquationParts(test_val, components))
        }
        Error(_) -> Error("Invalid test value: " <> test_str)
      }

    _ -> Error("Invalid line format: " <> line)
  }
}

/// Read theh input file and parse each line into an [EquationParts] and
/// return the list.
pub fn read_input(input_path) -> Input {
  let assert Ok(contents) = simplifile.read(input_path)
  string.split(contents, on: "\n")
  |> list.filter(fn(line) { string.length(string.trim(line)) > 0 })
  |> list.fold(Ok([]), fn(acc, line) {
    use so_far <- result.try(acc)
    use eq <- result.try(parse_line(line))
    Ok([eq, ..so_far])
  })
  |> result.map(list.reverse)
}
