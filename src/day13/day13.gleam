pub type Button {
  Button(dx: Int, dy: Int)
}

pub type Prize {
  Prize(x: Int, y: Int)
}

pub type Machine {
  Machine(a: Button, b: Button, prize: Prize)
}

pub type Input =
  Result(List(Machine), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day13/input.txt"

pub const example1_path = "test/day13/examples/example1.txt"

pub const example2_path = "test/day13/examples/example2.txt"
