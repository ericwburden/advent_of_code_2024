import common/runner
import day12/day12
import day12/parse
import day12/part1
import day12/part2

pub const part1_expected = 1_344_578

pub const part2_expected = 814_302

pub fn main() {
  let input = parse.read_input(day12.input_path)
  runner.run_day(12, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
