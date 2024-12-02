import day02/day02.{type Input, type Output, type Report}
import day02/part1.{Initializing, inspect_next_value, is_safe}
import gleam/list
import gleam/result

fn drop_value_at_index(lst: List(a), idx: Int) -> List(a) {
  let #(left, right) = list.split(lst, idx + 1)
  list.append(list.take(left, idx), right)
}

pub fn is_safe_report(report: Report) -> Bool {
  // Check over the report until we reach a value that causes the report
  // to be deemed unsafe.
  let partial_inspection =
    report
    |> list.scan(Initializing, inspect_next_value)
    |> list.take_while(is_safe)

  case list.length(partial_inspection) == list.length(report) {
    // If the full report is deemed safe, then we have our answer
    True -> True

    // However, if we reach a point in the report where the rising/falling pattern
    // does not continue, then we have narrowed down the problem value to either
    // the last value in the current pattern OR the value to either side of it.
    // We then check to see if the report would pass with any of these values
    // removed.
    False -> {
      let problem_index = list.length(partial_inspection) - 1
      list.range(problem_index - 1, problem_index + 1)
      |> list.filter(fn(x) { x >= 0 })
      |> list.any(fn(idx) {
        report
        |> drop_value_at_index(idx)
        |> list.fold(Initializing, inspect_next_value)
        |> is_safe
      })
    }
  }
}

pub fn solve(input: Input) -> Output {
  use input <- result.map(input)
  input |> list.filter(is_safe_report) |> list.length
}
