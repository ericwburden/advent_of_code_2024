import day20/day20
import day20/parse
import day20/part1
import day20/part2
import gleeunit/should

const part1_example1_answer = Ok(5)

const part2_example1_answer = Ok(285)

pub fn part1_example1_test() {
  day20.example1_path
  |> parse.read_input
  |> part1.solve(2, 20)
  |> should.equal(part1_example1_answer)
}

pub fn part2_example1_test() {
  day20.example1_path
  |> parse.read_input
  |> part2.solve(20, 50)
  |> should.equal(part2_example1_answer)
}
