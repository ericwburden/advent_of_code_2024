import common/types
import gleam/int
import gleam/io
import gleam/list

/// Minimal timing utilities used to measure durations in milliseconds.
///
/// These helpers wrap the Erlang VM's monotonic clock so we can measure how
/// long puzzles take to solve without introducing extra dependencies.
pub const native_units_per_millisecond = 1_000_000

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time_native() -> Int

/// Return the current monotonic time in milliseconds by converting the native
/// time units provided by the Erlang VM.
pub fn now_milliseconds() -> Int {
  monotonic_time_native() / native_units_per_millisecond
}

/// Given two timestamps produced by `now_milliseconds`, compute the elapsed
/// time in milliseconds.
pub fn elapsed_milliseconds(start: Int, finish: Int) -> Int {
  finish - start
}

pub fn run_day(day: Int, input: input, parts: List(types.RunnerPart(input))) {
  io.println("🗓️  Day " <> int.to_string(day))
  list.each(parts, fn(part) { run_part(input, part) })
}

fn run_part(input: input, part: types.RunnerPart(input)) {
  case part {
    types.IntPart(label: label, expected: expected, solver: solver) ->
      run_solver(input, label, expected, solver, fn(a, b) { a == b }, fn(value) {
        int.to_string(value)
      })

    types.StringPart(label: label, expected: expected, solver: solver) ->
      run_solver(input, label, expected, solver, fn(a, b) { a == b }, fn(value) {
        "\"" <> value <> "\""
      })
  }
}

fn run_solver(
  input: input,
  label: String,
  expected: output,
  solver: fn(input) -> Result(output, String),
  equals: fn(output, output) -> Bool,
  format: fn(output) -> String,
) {
  let start = now_milliseconds()

  case solver(input) {
    Ok(result) -> {
      let finish = now_milliseconds()
      let duration = elapsed_milliseconds(start, finish)
      case equals(result, expected) {
        True ->
          io.println(
            "  ✅ \u{001b}[1;32m"
            <> label
            <> " passed in "
            <> int.to_string(duration)
            <> "ms\u{001b}[0m",
          )

        False -> {
          io.println(
            "  🛑 \u{001b}[1;31m"
            <> label
            <> " failed in "
            <> int.to_string(duration)
            <> "ms\u{001b}[0m",
          )
          io.println("      expected: " <> format(expected))
          io.println("           got: " <> format(result))
        }
      }
    }

    Error(message) -> panic as message
  }
}

pub fn int_part(
  label: String,
  expected: Int,
  solver: fn(input) -> Result(Int, String),
) -> types.RunnerPart(input) {
  types.IntPart(label: label, expected: expected, solver: solver)
}

pub fn string_part(
  label: String,
  expected: String,
  solver: fn(input) -> Result(String, String),
) -> types.RunnerPart(input) {
  types.StringPart(label: label, expected: expected, solver: solver)
}
