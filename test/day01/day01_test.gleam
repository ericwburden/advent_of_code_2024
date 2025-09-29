import day01/day01
import day01/parse
import day01/part1
import day01/part2
import gleeunit/should

const example1_answer = Ok(11)

const example2_answer = Ok(31)

pub fn example1_test() {
  day01.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day01.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
