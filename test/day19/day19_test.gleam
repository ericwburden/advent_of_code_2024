import day19/day19
import day19/parse
import day19/part1
import day19/part2
import gleeunit/should

const part1_example1_answer = Ok(6)

const part2_example1_answer = Ok(0)

pub fn part1_example1_test() {
  day19.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example1_answer)
}
// pub fn part2_example1_test() {
//   day19.example1_path
//   |> parse.read_input
//   |> part2.solve
//   |> should.equal(part2_example1_answer)
// }
