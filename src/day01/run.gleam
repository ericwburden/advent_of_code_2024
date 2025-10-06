import common/runner
import day01/day01
import day01/parse
import day01/part1
import day01/part2

pub const part1_expected = 2_176_849

pub const part2_expected = 23_384_288

pub fn main() {
  let input = parse.read_input(day01.input_path)
  runner.run_day(1, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
