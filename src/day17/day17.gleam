import gleam/dict

pub type Registers {
  Registers(a: Int, b: Int, c: Int)
}

pub type ProgramState {
  ProgramState(
    registers: Registers,
    instruction_pointer: Int,
    output: List(Int),
  )
}

pub type Instruction {
  ADV(value: Int)
  BXL(value: Int)
  BST(value: Int)
  JNZ(value: Int)
  BXC
  OUT(value: Int)
  BDV(value: Int)
  CDV(value: Int)
}

pub type InstructionSet =
  dict.Dict(Int, Instruction)

pub type Input =
  Result(#(ProgramState, List(Int)), String)

pub type Output =
  Result(String, String)

pub const input_path = "inputs/day17/input.txt"

pub const example1_path = "test/day17/examples/example1.txt"

pub const example2_path = "test/day17/examples/example2.txt"
