import day02/day02.{type Input, type Output, type Report}
import gleam/list
import gleam/result

/// Let's code a state machine! The [SafetyInspector] holds the state of our
/// knowledge as we review a [Report] to determine whether it is safe or unsafe.
/// We have variants to cover the case where we haven't reviewed any numbers yet
/// ([Initializing]), the case where we've only reviewed one number and don't yet
/// know whether the report contains a rising or falling pattern ([Priming]),
/// cases where we're following a rising or falling pattern in the report 
/// numbers ([Increasing/Decreasing]), and the case where we've already deemed
/// the [Report] [Unsafe]. The values associated with [Priming], [Increasing], and
/// [Decreasing] is the last checked value in the [Report].
pub type SafetyInspector {
  Initializing
  Priming(Int)
  Increasing(Int)
  Decreasing(Int)
  Unsafe
}

/// Indicates whether the [SafetyInspector] is in a safe state.
pub fn is_safe(inspector: SafetyInspector) -> Bool {
  case inspector {
    Unsafe -> False
    _ -> True
  }
}

/// Given the current state of the [SafetyInspector] and the next number to inspect,
/// determine whether the next state of the [SafetyInspector].
pub fn inspect_next_value(
  inspector: SafetyInspector,
  next_value: Int,
) -> SafetyInspector {
  case inspector {
    // If no values have been checked yet, we prime the inspector with the first number
    Initializing -> Priming(next_value)

    // If only one value has been checked, we need to determine whether the next
    // value is the start of a rising or falling pattern.
    Priming(x) if next_value > x && next_value - x <= 3 ->
      Increasing(next_value)
    Priming(x) if next_value < x && x - next_value <= 3 ->
      Decreasing(next_value)

    // If we're already in a rising or falling pattern, we need to determine whether
    // that pattern is continuing.
    Increasing(x) if next_value > x && next_value - x <= 3 ->
      Increasing(next_value)
    Decreasing(x) if next_value < x && x - next_value <= 3 ->
      Decreasing(next_value)

    // For any other outcome, we've reached an usafe state.
    _ -> Unsafe
  }
}

/// Given a [Report], inspect each value in sequence to determine whether the 
/// report is a safe or unsafe report.
pub fn is_safe_report(report: Report) -> Bool {
  report
  |> list.fold(from: Initializing, with: inspect_next_value)
  |> is_safe
}

/// Solve part 1. Check each report to determine whether all the values in that
/// report are either increasing between 1-3 or decreasing between 1-3 for each
/// subsequent value. A report that follows that increasing or decreasing pattern
/// for all numbers is considered safe. Return the number of safe reports.
pub fn solve(input: Input) -> Output {
  use input <- result.map(input)
  input |> list.filter(is_safe_report) |> list.length
}
