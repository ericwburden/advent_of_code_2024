import common/runner
import day17/day17
import day17/parse
import day17/part1
import day17/part2

pub const part1_expected = ""

pub const part2_expected = ""

pub fn main() {
  let input = parse.read_input(day17.input_path)
  runner.run_day(17, input, [
    runner.string_part("Part 1", part1_expected, part1.solve),
    runner.string_part("Part 2", part2_expected, part2.solve),
  ])
}
