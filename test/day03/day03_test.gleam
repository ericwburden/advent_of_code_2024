import day03/day03
import day03/parse
import day03/part1
import day03/part2
import gleeunit/should

const example1_answer = Ok(161)

const example2_answer = Ok(48)

pub fn example1_test() {
  day03.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day03.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
