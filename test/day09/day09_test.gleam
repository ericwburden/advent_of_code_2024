import day09/day09
import day09/parse
import day09/part1
import day09/part2
import gleeunit/should

const example1_answer = Ok(1928)

const part1_answer = Ok(6_430_446_922_192)

const example2_answer = Ok(2858)

const part2_answer = Ok(6_460_170_593_016)

pub fn example1_test() {
  day09.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day09.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day09.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day09.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
