import day05/day05
import day05/parse
import day05/part1
import day05/part2
import gleeunit/should

const example1_answer = Ok(143)

const part1_answer = Ok(5087)

const example2_answer = Ok(123)

const part2_answer = Ok(4971)

pub fn example1_test() {
  day05.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day05.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day05.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day05.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
