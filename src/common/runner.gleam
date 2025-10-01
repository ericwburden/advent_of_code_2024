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

pub fn run_day(
  day: Int,
  input: input,
  parts: List(#(String, Int, fn(input) -> Result(Int, String))),
) {
  parts
  |> list.each(fn(part) { run_part(day, input, part) })
}

fn run_part(
  day: Int,
  input: input,
  part: #(String, Int, fn(input) -> Result(Int, String)),
) {
  let #(label, expected, solver) = part
  let start = now_milliseconds()

  case solver(input) {
    Ok(result) -> {
      let finish = now_milliseconds()
      let duration = elapsed_milliseconds(start, finish)
      case result == expected {
        True ->
          io.println(
            "✅ Passed Day "
            <> int.to_string(day)
            <> ", "
            <> label
            <> " in "
            <> int.to_string(duration)
            <> "ms",
          )
        False ->
          panic as { "🛑 Failed Day " <> int.to_string(day) <> ", " <> label }
      }
    }
    Error(message) -> panic as message
  }
}
