import common/runner
import day11/day11
import day11/parse
import day11/part1
import day11/part2

pub const part1_expected = 197_357

pub const part2_expected = 234_568_186_890_978

pub fn main() {
  let input = parse.read_input(day11.input_path)
  runner.run_day(11, input, [
    runner.int_part("Part 1", part1_expected, part1.solve),
    runner.int_part("Part 2", part2_expected, part2.solve),
  ])
}
