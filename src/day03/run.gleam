import common/runner
import day03/day03
import day03/parse
import day03/part1
import day03/part2

pub const part1_expected = 153_469_856

pub const part2_expected = 77_055_967

pub fn main() {
  let input = parse.read_input(day03.input_path)
  runner.run_day(3, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
