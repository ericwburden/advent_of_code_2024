import day07/day07.{type Input}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn parse_space_separated_int_list(
  input: String,
) -> Result(List(Int), String) {
  let tokens =
    input
    |> string.trim
    |> string.split(" ")
    |> list.filter(fn(s) { s != "" })

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

pub fn parse_line(line: String) -> Result(day07.EquationParts, String) {
  case string.split(line, ":") {
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
