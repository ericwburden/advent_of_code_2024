import day02/day02
import day02/parse
import day02/part1
import day02/part2
import gleam/list
import gleeunit/should

const example1_answer = Ok(2)

const example2_answer = Ok(4)

const individual_report_test_cases = [
  #([8, 5, 4, 3, 2], True, True),
  #([2, 3, 4, 5, 7], True, True),
  #([1, 3, 2, 4, 5], False, True),
  #([8, 6, 4, 4, 1], False, True),
  #([5, 4, 6, 7, 8], False, True),
  #([5, 6, 4, 3, 2], False, True),
  #([5, 6, 4, 7, 8], False, True),
  #([5, 6, 7, 8, 1], False, True),
  #([1, 5, 6, 7, 8], False, True),
  #([1, 2, 2, 4, 5], False, True),
  #([4, 1, 4, 7, 8], False, True),
  #([4, 1, 4, 7, 6], False, False),
]

fn test_individual_edge_case(test_case: #(day02.Report, Bool, Bool)) {
  let #(report, part1_result, part2_result) = test_case
  part1.is_safe_report(report) |> should.equal(part1_result)
  part2.is_safe_report(report) |> should.equal(part2_result)
}

pub fn edge_cases_test() {
  individual_report_test_cases |> list.each(test_individual_edge_case)
}

pub fn example1_test() {
  day02.example1_path
  |> parse.read_input
  |> part1.solve
  |> should.equal(example1_answer)
}

pub fn example2_test() {
  day02.example1_path
  |> parse.read_input
  |> part2.solve
  |> should.equal(example2_answer)
}
