/// A nice data type for the page ordering rules
pub type PageOrderingRule {
  PageOrderingRule(page: Int, after: Int)
}

pub type Input =
  Result(#(List(PageOrderingRule), List(List(Int))), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day05/input.txt"

pub const example1_path = "test/day05/examples/example1.txt"

pub const example2_path = "test/day05/examples/example2.txt"
