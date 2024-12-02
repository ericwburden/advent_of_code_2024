import day01/day01
import day01/parse
import day01/part1
import day01/part2
import gleeunit/should

const example1_answer = Ok(11)

const part1_answer = Ok(2_176_849)

const example2_answer = Ok(31)

const part2_answer = Ok(23_384_288)

pub fn example1_test() {
  day01.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day01.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day01.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day01.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
