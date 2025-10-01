import day13/day13
import day13/parse
import day13/part1
import day13/part2
import gleeunit/should

const example1_answer = Ok(480)

const example2_answer = Ok(875_318_608_908)

pub fn example1_test() {
  day13.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day13.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
