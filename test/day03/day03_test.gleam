import day03/day03
import day03/parse
import day03/part1
import day03/part2
import gleeunit/should

const example1_answer = Ok(161)

const part1_answer = Ok(153_469_856)

const example2_answer = Ok(48)

const part2_answer = Ok(77_055_967)

pub fn example1_test() {
  day03.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day03.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day03.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day03.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
