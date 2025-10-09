import day20/day20
import day20/parse
import day20/part1
import day20/part2
import common/runner

pub const part1_expected = 0

pub const part2_expected = 0

pub fn main() {
  let input = parse.read_input(day20.input_path)
  runner.run_day(20, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
