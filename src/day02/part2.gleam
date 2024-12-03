import day02/day02.{type Input, type Output, type Report}
import day02/part1.{Initializing, inspect_next_value, is_safe}
import gleam/list
import gleam/result

/// Given a list and an index in that list, return the list with the indicated
/// index removed.
fn drop_value_at_index(lst: List(a), idx: Int) -> List(a) {
  let #(left, right) = list.split(lst, idx + 1)
  list.append(list.take(left, idx), right)
}

/// Since we're able to ignore one of the values in the report, determining whether
/// a [Report] is safe or unsafe is a bit more complicated. A report may still be
/// considered safe without ignoring any values, but if not...
pub fn is_safe_report(report: Report) -> Bool {
  // Check over the report until we reach a value that causes the report
  // to be deemed unsafe.
  let partial_inspection =
    report
    |> list.scan(Initializing, inspect_next_value)
    |> list.take_while(is_safe)

  case list.length(partial_inspection) == list.length(report) {
    // If all values are checked and the report is not found to be unsafe, then
    // we can skip attempting to ignore any values.
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

/// For part 2, we've got the benefit of the Problem Dampener to smooth over a single
/// discrepancy in each report. If a report can be made safe by ignoring a single
/// value, then it's still considered safe. Count up all the safe reports under these
/// more lenient conditions and report that number.
pub fn solve(input: Input) -> Output {
  use input <- result.map(input)
  input |> list.filter(is_safe_report) |> list.length
}
