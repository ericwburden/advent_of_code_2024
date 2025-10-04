import day16/day16.{type Input, type Output, example1_path}
import day16/navigation
import day16/parse
import gleam/int
import gleam/io
import gleam/result

/// Part 1 asks for the minimum cost required to travel from the start to the
/// exit. All of the heavy lifting happens inside the shared `navigation`
/// helpers; here we simply parse the input, run Dijkstra once, and translate
/// the result into the expected `Result(Int, String)` wrapper.
pub fn solve(input: Input) -> Output {
  use valid_input <- result.try(input)
  let start = navigation.start_state(valid_input)
  let walls = navigation.walls(valid_input)
  let goal = navigation.goal(valid_input)

  let distances = navigation.dijkstra([#(start, 0)], walls)

  case navigation.min_cost_to_goal(distances, goal) {
    Ok(cost) -> Ok(cost)
    Error(_) -> Error("No path found from the start to the end position")
  }
}

/// Small helper binary so we can smoke-test the solver against the first sample
/// maze from the command line.
pub fn main() -> Nil {
  let solve_result = example1_path |> parse.read_input |> solve
  case solve_result {
    Ok(score) -> io.println(int.to_string(score))
    Error(message) -> io.println(message)
  }
}
