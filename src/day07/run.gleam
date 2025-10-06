import common/runner
import day07/day07
import day07/parse
import day07/part1
import day07/part2

pub const part1_expected = 2_664_460_013_123

pub const part2_expected = 426_214_131_924_213

pub fn main() {
  let input = parse.read_input(day07.input_path)
  runner.run_day(7, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
