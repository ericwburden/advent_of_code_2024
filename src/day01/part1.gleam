import day01/day01.{type Input, type Output}
import gleam/int
import gleam/list
import gleam/result

/// Solve part 1. No helper functions needed for this, really. Yay for simple puzzles
/// on the first day!
pub fn solve(input: Input) -> Output {
  // Assume our input parsed
  use input_ok <- result.map(input)

  // Separate the input lists into two lists, then sort both.
  let #(left_list, right_list) = list.unzip(input_ok)
  let sorted_left_list = list.sort(left_list, by: int.compare)
  let sorted_right_list = list.sort(right_list, by: int.compare)

  // Now zip the sorted lists back together, so that the first value in the left list
  // is paired with the first value in the right list, and so on. Then get the
  // absolute value of the differences between the pairs and add those differences
  // together for the answer.
  list.zip(sorted_left_list, sorted_right_list)
  |> list.map(fn(x) { x.1 - x.0 })
  |> list.map(int.absolute_value)
  |> int.sum
}
