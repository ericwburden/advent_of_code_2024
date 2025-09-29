import day09/day09
import day09/parse
import day09/part1
import day09/part2
import gleeunit/should

const example1_answer = Ok(1928)

const example2_answer = Ok(2858)

pub fn example1_test() {
  day09.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day09.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
