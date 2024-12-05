import day04/day04
import day04/parse
import day04/part1
import day04/part2
import gleeunit/should

const example1_answer = Ok(18)

const part1_answer = Ok(2297)

const example2_answer = Ok(9)

const part2_answer = Ok(1745)

pub fn example1_test() {
  day04.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day04.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day04.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day04.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
