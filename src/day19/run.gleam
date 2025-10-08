import common/runner
import day19/day19
import day19/parse
import day19/part1
import day19/part2

pub const part1_expected = 319

pub const part2_expected = 692_575_723_305_545

pub fn main() {
  let input = parse.read_input(day19.input_path)
  runner.run_day(19, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
