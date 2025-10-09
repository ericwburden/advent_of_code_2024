import common/runner
import day20/day20
import day20/parse
import day20/part1
import day20/part2

/// Known answer for the real input; used to flag regressions.
pub const part1_expected = 1393

/// Part 2 reference answer for the real input.
pub const part2_expected = 990_096

pub fn main() {
  let input = parse.read_input(day20.input_path)
  let part1_solve = fn(input) {
    part1.solve(
      input,
      part1.default_cheat_distance,
      part1.default_savings_threshold,
    )
  }
  let part2_solve = fn(input) {
    part2.solve(input, part2.cheat_distance, part2.savings_threshold)
  }
  runner.run_day(20, input, [
    // Wire part 1 into the shared runner harness.
    runner.int_part("Part 1", part1_expected, part1_solve),
    // And part 2, which uses a wider cheat allowance.
    runner.int_part("Part 2", part2_expected, part2_solve),
  ])
}
