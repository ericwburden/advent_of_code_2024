import common/runner
import day20/day20
import day20/parse
import day20/part1
import day20/part2

pub const part1_expected = 1393

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
    runner.int_part("Part 1", part1_expected, part1_solve),
    runner.int_part("Part 2", part2_expected, part2_solve),
  ])
}
