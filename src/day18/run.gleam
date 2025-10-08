import common/runner
import day18/day18
import day18/parse
import day18/part1
import day18/part2

pub const part1_expected = 306

pub const part2_expected = "38,63"

/// Hook the Day 18 solvers into the shared runner harness.
pub fn main() {
  let input = parse.read_input(day18.input_path)
  let part1_solve = fn(input) { part1.solve(input, 70, 1024) }
  let part2_solve = fn(input) { part2.solve(input, 70, 1024) }
  runner.run_day(18, input, [
    runner.int_part("Part 1", part1_expected, part1_solve),
    runner.string_part("Part 2", part2_expected, part2_solve),
  ])
}
