import day10/day10
import day10/parse
import day10/part1
import day10/part2
import gleeunit/should

const example1_answer = Ok(36)

const part1_answer = Ok(514)

const example2_answer = Ok(81)

const part2_answer = Ok(1162)

pub fn example1_test() {
  day10.example2_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day10.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day10.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day10.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
