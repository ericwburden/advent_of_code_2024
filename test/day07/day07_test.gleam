import day07/day07
import day07/parse
import day07/part1
import day07/part2
import gleeunit/should

const example1_answer = Ok(3749)

const part1_answer = Ok(2_664_460_013_123)

const example2_answer = Ok(11_387)

const part2_answer = Ok(426_214_131_924_213)

pub fn example1_test() {
  day07.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day07.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day07.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day07.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
