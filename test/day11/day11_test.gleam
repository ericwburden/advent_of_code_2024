import day11/day11
import day11/parse
import day11/part1
import day11/part2
import gleeunit/should

const example1_answer = Ok(55_312)

const part1_answer = Ok(197_357)

const example2_answer = Ok(65_601_038_650_482)

const part2_answer = Ok(234_568_186_890_978)

pub fn example1_test() {
  day11.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn part1_test() {
  day11.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day11.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

pub fn part2_test() {
  day11.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
