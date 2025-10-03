import day15/day15
import day15/parse
import day15/part1
import day15/part2
import gleeunit/should

const part1_example1_answer = Ok(2028)

const part1_example2_answer = Ok(10_092)

const part2_example2_answer = Ok(9021)

pub fn part1_example1_test() {
  day15.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example1_answer)
}

pub fn part1_example2_test() {
  day15.example2_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example2_answer)
}

pub fn part2_example2_test() {
  day15.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_example2_answer)
}
