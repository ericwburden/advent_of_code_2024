import gleam/dict

/// Shared data structures for Day 17, representing the registers, program
/// state, decoded instructions, and the Result wrappers both parts return.
pub type Registers {
  Registers(a: Int, b: Int, c: Int)
}

/// The full VM state tracked while executing a Day 17 program.
pub type ProgramState {
  ProgramState(
    registers: Registers,
    instruction_pointer: Int,
    output: List(Int),
  )
}

/// All possible instructions emitted by the parser. Each carries the raw
/// operand value from the puzzle input when applicable.
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

/// A decoded program keyed by instruction pointer.
pub type InstructionSet =
  dict.Dict(Int, Instruction)

/// Parsed puzzle input for Day 17.
pub type Input =
  Result(#(ProgramState, List(Int)), String)

/// Solver output shared by both parts.
pub type Output =
  Result(String, String)

pub const input_path = "inputs/day17/input.txt"

pub const example1_path = "test/day17/examples/example1.txt"

pub const example2_path = "test/day17/examples/example2.txt"
