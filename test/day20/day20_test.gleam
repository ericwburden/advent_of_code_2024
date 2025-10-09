import day20/day20
import day20/parse
import day20/part1
import gleeunit/should

const part1_example1_answer = Ok(0)

pub fn part1_example1_test() {
  day20.example1_path
  |> parse.read_input
  |> part1.solve(part1.default_cheat_distance, part1.default_savings_threshold)
  |> should.equal(part1_example1_answer)
}

// pub fn part2_example1_test() {
//   day20.example1_path
//   |> parse.read_input
//   |> part2.solve
//   |> should.equal(part2_example1_answer)
// }
