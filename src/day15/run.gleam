import common/runner
import day15/day15
import day15/parse
import day15/part1
import day15/part2

pub const part1_expected = 1_421_727

pub const part2_expected = 1_463_160

pub fn main() {
  let input = parse.read_input(day15.input_path)
  runner.run_day(15, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
