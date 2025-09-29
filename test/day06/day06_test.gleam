import day06/day06
import day06/parse
import day06/part1
import day06/part2
import gleeunit/should

const example1_answer = Ok(41)

const example2_answer = Ok(6)

pub fn example1_test() {
  day06.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day06.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
