import common/runner
import day14/day14
import day14/parse
import day14/part1
import day14/part2

pub const part1_expected = 226_548_000

pub const part2_expected = 7753

pub fn main() {
  let input = parse.read_input(day14.input_path)
  // Update the solve function to include the grid size for the floor using
  // the real input, since the tests rely on a smaller grid size.
  let part1_solve = fn(input) { part1.solve(input, 101, 103) }
  let part2_solve = fn(input) { part2.solve(input, 101, 103) }

  runner.run_day(14, input, [
    runner.int_part("Part 1", part1_expected, part1_solve),
    runner.int_part("Part 2", part2_expected, part2_solve),
  ])
}
