import common/runner
import day02/day02
import day02/parse
import day02/part1
import day02/part2

pub const part1_expected = 269

pub const part2_expected = 337

pub fn main() {
  let input = parse.read_input(day02.input_path)
  runner.run_day(2, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
