import common/runner
import day08/day08
import day08/parse
import day08/part1
import day08/part2

pub const part1_expected = 254

pub const part2_expected = 951

pub fn main() {
  let input = parse.read_input(day08.input_path)
  runner.run_day(8, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
