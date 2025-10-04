import common/runner
import day16/day16
import day16/parse
import day16/part1
import day16/part2

pub const part1_expected = 85_420

pub const part2_expected = 492

pub fn main() {
  let input = parse.read_input(day16.input_path)
  runner.run_day(16, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
