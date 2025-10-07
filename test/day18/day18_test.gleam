import day18/day18
import day18/parse
import day18/part1
import day18/part2
import gleeunit/should

const part1_example1_answer = Ok(22)

const part2_example1_answer = Ok("6,1")

pub fn part1_example1_test() {
  day18.example1_path
  |> parse.read_input
  |> part1.solve(6, 12)
  |> should.equal(part1_example1_answer)
}

pub fn part2_example1_test() {
  day18.example1_path
  |> parse.read_input
  |> part2.solve(6, 12)
  |> should.equal(part2_example1_answer)
}
