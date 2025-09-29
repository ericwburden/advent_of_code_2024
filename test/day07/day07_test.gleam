import day07/day07
import day07/parse
import day07/part1
import day07/part2
import gleeunit/should

const example1_answer = Ok(3749)

const example2_answer = Ok(11_387)

pub fn example1_test() {
  day07.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day07.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
