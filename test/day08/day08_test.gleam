import day08/day08
import day08/parse
import day08/part1
import day08/part2
import gleeunit/should

const example1_answer = Ok(14)

const part1_answer = Ok(254)

const example2_answer = Ok(34)

const part2_answer = Ok(951)

pub fn example1_test() {
  day08.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day08.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day08.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day08.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
