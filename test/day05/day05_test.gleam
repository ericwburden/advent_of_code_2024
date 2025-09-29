import day05/day05
import day05/parse
import day05/part1
import day05/part2
import gleeunit/should

const example1_answer = Ok(143)

const example2_answer = Ok(123)

pub fn example1_test() {
  day05.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day05.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
