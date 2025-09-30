import day12/day12
import day12/parse
import day12/part1
import day12/part2
import gleeunit/should

const example1_answer = Ok(1930)

const example2_answer = Ok(1206)

pub fn example1_test() {
  day12.example2_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day12.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
