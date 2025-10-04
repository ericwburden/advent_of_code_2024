import day16/day16.{type Input, type Output, ValidInput, example1_path}
import day16/dijkstra
import day16/parse
import gleam/int
import gleam/io
import gleam/result

/// Part 1 asks for the minimum cost required to travel from the start to the
/// exit. All of the heavy lifting happens inside the shared `dijkstra`
/// helpers; here we simply parse the input, run Dijkstra once, and translate
/// the result into the expected `Result(Int, String)` wrapper.
pub fn solve(input: Input) -> Output {
  use valid_input <- result.try(input)
  let ValidInput(start, goal, walls) = valid_input

  let distances = dijkstra.map_shortest_distances_from_start(start, walls)

  case dijkstra.cost_of_shortest_path(distances, goal) {
    Ok(cost) -> Ok(cost)
    Error(_) -> Error("No path found from the start to the end position")
  }
}

pub fn main() -> Nil {
  let solve_result = example1_path |> parse.read_input |> solve
  case solve_result {
    Ok(score) -> io.println(int.to_string(score))
    Error(message) -> io.println(message)
  }
}
