import common/runner
import day06/day06
import day06/parse
import day06/part1
import day06/part2

pub const part1_expected = 4454

pub const part2_expected = 1503

pub fn main() {
  let input = parse.read_input(day06.input_path)
  runner.run_day(6, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
