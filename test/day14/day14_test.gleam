import day14/day14
import day14/parse
import day14/part1
import gleeunit/should

const example1_answer = Ok(12)

pub fn example1_test() {
  day14.example1_path
  |> parse.read_input
  |> fn(input) { part1.solve(input, 11, 7) }
  |> should.equal(example1_answer)
}
// There is no test for part 2, because the example doesn't involve part 2 at all
