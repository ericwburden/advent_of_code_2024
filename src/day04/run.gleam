import common/runner
import day04/day04
import day04/parse
import day04/part1
import day04/part2

pub const part1_expected = 2297

pub const part2_expected = 1745

pub fn main() {
  let input = parse.read_input(day04.input_path)
  runner.run_day(4, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
