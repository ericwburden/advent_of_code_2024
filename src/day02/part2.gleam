import day02/day02.{type Input, type Output, type Report}
import day02/part1.{Initializing, Unsafe, inspect_next_value}
import gleam/list
import gleam/result

fn is_safe(inspector: part1.SafetyInspector) -> Bool {
  case inspector {
    Unsafe -> False
    _ -> True
  }
}

fn drop_value_at_index(lst: List(a), idx: Int) -> List(a) {
  let #(left, right) = list.split(lst, idx + 1)
  list.append(list.take(left, idx), right)
}

pub fn brute_force(report: Report) {
  list.range(0, list.length(report) - 1)
  |> list.any(fn(idx) {
    report
    |> drop_value_at_index(idx)
    |> list.fold(Initializing, inspect_next_value)
    |> is_safe
  })
}

pub fn apply_problem_dampener(report: Report) {
  let problem_index =
    list.scan(report, Initializing, inspect_next_value)
    |> list.take_while(is_safe)
    |> list.length()

  // The issue is between the last value of the left list and the first value
  // of the right list. First, check to see if dropping the last value from the left
  // list will fix the report.
  let left_list_trimmed = list.take(report, problem_index - 1)
  let right_list = list.drop(report, problem_index)
  let is_safe_with_left_value_dropped =
    list.append(left_list_trimmed, right_list)
    |> list.fold(Initializing, inspect_next_value)
    |> is_safe

  // If the report is still unsafe after dropping the first potentially bad value, 
  // try it after dropping the second potentially bad value
  case is_safe_with_left_value_dropped {
    True -> True
    False -> {
      let left_list = list.take(report, problem_index)
      let right_list_trimmed = list.drop(report, problem_index + 1)
      list.append(left_list, right_list_trimmed)
      |> list.fold(Initializing, inspect_next_value)
      |> is_safe
    }
  }
}

pub fn is_safe_report(report: Report) -> Bool {
  let partial_inspection =
    report
    |> list.scan(Initializing, inspect_next_value)
    |> list.take_while(is_safe)

  case list.length(partial_inspection) == list.length(report) {
    True -> True
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
