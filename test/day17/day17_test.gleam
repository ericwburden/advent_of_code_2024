import day17/day17
import day17/parse
import day17/part1
import day17/part2
import gleeunit/should

const part1_example1_answer = Ok("4,6,3,5,6,3,5,2,1,0")

const part2_example2_answer = Ok("117440")

pub fn part1_example1_test() {
  day17.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_example1_answer)
}

pub fn part2_example2_test() {
  day17.example2_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_example2_answer)
}
