import common/runner
import day10/day10
import day10/parse
import day10/part1
import day10/part2

pub const part1_expected = 514

pub const part2_expected = 1162

pub fn main() {
  let input = parse.read_input(day10.input_path)
  runner.run_day(10, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
