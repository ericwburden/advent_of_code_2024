import day14/day14
import day14/parse
import day14/part1
import day14/part2
import gleeunit/should

const example1_answer = Nil

const example2_answer = Nil

pub fn example1_test() {
  day14.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

// pub fn example2_test() {
//   day14.example2_path
//   |> parse.read_input
//   |> part2.solve
//   |> should.equal(example2_answer)
// }
