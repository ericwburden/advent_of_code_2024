import day02/day02.{type Input, type Output, type Report}
import gleam/list
import gleam/result

pub type SafetyInspector {
  Initializing
  Neutral(Int)
  Increasing(Int)
  Decreasing(Int)
  Unsafe
}

pub fn is_safe(inspector: SafetyInspector) -> Bool {
  case inspector {
    Unsafe -> False
    _ -> True
  }
}

pub fn inspect_next_value(
  inspector: SafetyInspector,
  next_value: Int,
) -> SafetyInspector {
  case inspector {
    Initializing -> Neutral(next_value)
    Neutral(x) if next_value > x && next_value - x <= 3 ->
      Increasing(next_value)
    Neutral(x) if next_value < x && x - next_value <= 3 ->
      Decreasing(next_value)
    Increasing(x) if next_value > x && next_value - x <= 3 ->
      Increasing(next_value)
    Decreasing(x) if next_value < x && x - next_value <= 3 ->
      Decreasing(next_value)
    _ -> Unsafe
  }
}

pub fn is_safe_report(report: Report) -> Bool {
  report
  |> list.fold(from: Initializing, with: inspect_next_value)
  |> is_safe
}

pub fn solve(input: Input) -> Output {
  use input <- result.map(input)

  input |> list.filter(is_safe_report) |> list.length
}
