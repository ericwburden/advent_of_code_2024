import day06/day06
import day06/parse
import day06/part1
import day06/part2
import gleeunit/should

const example1_answer = Ok(41)

const part1_answer = Ok(4454)

const example2_answer = Ok(6)

const part2_answer = Ok(1503)

pub fn example1_test() {
  day06.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

// 4453 is too low
pub fn part1_test() {
  day06.input_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(part1_answer)
}

pub fn example2_test() {
  day06.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}

// If running the test times out the gleeunit testing framework, we need to 
// get the answer by running `gleam run -m day06/part2`
pub fn part2_test() {
  day06.input_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(part2_answer)
}
