import common/runner
import day13/day13
import day13/parse
import day13/part1
import day13/part2

pub const part1_expected = 31_897

pub const part2_expected = 87_596_249_540_359

pub fn main() {
  let input = parse.read_input(day13.input_path)
  runner.run_day(13, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
