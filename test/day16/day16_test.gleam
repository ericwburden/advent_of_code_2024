import day16/day16
import day16/parse
import day16/part1
import day16/part2
import gleeunit/should

const part1_example1_answer = Ok(7036)

const part1_example2_answer = Ok(11_048)

const part2_example1_answer = Ok(45)

const part2_example2_answer = Ok(64)

pub fn part1_example1_test() {
  day16.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example1_answer)
}

pub fn part1_example2_test() {
  day16.example2_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example2_answer)
}

pub fn part2_example1_test() {
  day16.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_example1_answer)
}

pub fn part2_example2_test() {
  day16.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_example2_answer)
}
