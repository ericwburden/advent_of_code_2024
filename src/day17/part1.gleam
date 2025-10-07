import day17/day17.{type Input, type InstructionSet, type Output}
import day17/parse
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Errors surfaced while executing the Day 17 VM.
pub type ErrorType {
  Halted
  InvalidRegister(String)
}

/// Convert the raw opcode/operand pairs into the strongly typed instructions
/// defined in `day17.gleam`.
fn parse_instruction(opcode: Int, operand: Int) -> day17.Instruction {
  case opcode {
    0 -> day17.ADV(value: operand)
    1 -> day17.BXL(value: operand)
    2 -> day17.BST(value: operand)
    3 -> day17.JNZ(value: operand)
    4 -> day17.BXC
    5 -> day17.OUT(value: operand)
    6 -> day17.BDV(value: operand)
    7 -> day17.CDV(value: operand)
    _ -> panic as "Unexpected opcode"
  }
}

/// Build the instruction set dictionary keyed by instruction pointer.
pub fn instruction_set_from_raw(raw: List(Int)) -> InstructionSet {
  raw
  |> list.window_by_2
  |> list.index_map(fn(pair, index) { #(index, pair) })
  |> list.fold(dict.new(), fn(acc, entry) {
    let #(index, pair) = entry
    let #(opcode, operand) = pair
    dict.insert(acc, index, parse_instruction(opcode, operand))
  })
}

/// Resolve the "combo" operand addressing mode described in the puzzle text.
fn combo_operand_value(registers: day17.Registers, operand: Int) -> Int {
  case operand {
    4 -> registers.a
    5 -> registers.b
    6 -> registers.c
    _ -> operand
  }
}

/// Implementations for each opcode follow, mutating the target register(s) as
/// specified by the puzzle.
fn adv(registers: day17.Registers, operand: Int) -> day17.Registers {
  let denominator = combo_operand_value(registers, operand)
  let new_a = int.bitwise_shift_right(registers.a, denominator)
  day17.Registers(new_a, registers.b, registers.c)
}

fn bxl(registers: day17.Registers, operand: Int) -> day17.Registers {
  let new_b = int.bitwise_exclusive_or(registers.b, operand)
  day17.Registers(registers.a, new_b, registers.c)
}

fn bst(registers: day17.Registers, operand: Int) -> day17.Registers {
  let op_val = combo_operand_value(registers, operand)
  let new_b = int.bitwise_and(op_val, 7)
  day17.Registers(registers.a, new_b, registers.c)
}

fn jnz(registers: day17.Registers, operand: Int, pointer: Int) -> Int {
  case registers.a == 0 {
    True -> pointer + 2
    False -> operand
  }
}

fn bxc(registers: day17.Registers) -> day17.Registers {
  let new_b = int.bitwise_exclusive_or(registers.b, registers.c)
  day17.Registers(registers.a, new_b, registers.c)
}

fn out(registers: day17.Registers, operand: Int) -> Int {
  let op_val = combo_operand_value(registers, operand)
  int.bitwise_and(op_val, 7)
}

fn bdv(registers: day17.Registers, operand: Int) -> day17.Registers {
  let denominator = combo_operand_value(registers, operand)
  let new_b = int.bitwise_shift_right(registers.a, denominator)
  day17.Registers(registers.a, new_b, registers.c)
}

fn cdv(registers: day17.Registers, operand: Int) -> day17.Registers {
  let denominator = combo_operand_value(registers, operand)
  let new_c = int.bitwise_shift_right(registers.a, denominator)
  day17.Registers(registers.a, registers.b, new_c)
}

/// Helper to build the next `ProgramState` without repeating all three fields.
fn build_program_state(
  registers: day17.Registers,
  pointer: Int,
  output: List(Int),
) -> day17.ProgramState {
  day17.ProgramState(
    registers: registers,
    instruction_pointer: pointer,
    output: output,
  )
}

/// Advance the VM by executing the instruction at the current pointer.
pub fn next(
  state: day17.ProgramState,
  instructions: InstructionSet,
) -> Result(day17.ProgramState, ErrorType) {
  let day17.ProgramState(reg, p, output) = state
  case dict.get(instructions, p) {
    Error(Nil) -> Error(Halted)
    Ok(instruction) ->
      case instruction {
        day17.ADV(v) -> Ok(build_program_state(adv(reg, v), p + 2, output))
        day17.BDV(v) -> Ok(build_program_state(bdv(reg, v), p + 2, output))
        day17.BST(v) -> Ok(build_program_state(bst(reg, v), p + 2, output))
        day17.BXC -> Ok(build_program_state(bxc(reg), p + 2, output))
        day17.BXL(v) -> Ok(build_program_state(bxl(reg, v), p + 2, output))
        day17.CDV(v) -> Ok(build_program_state(cdv(reg, v), p + 2, output))
        day17.JNZ(v) -> Ok(build_program_state(reg, jnz(reg, v, p), output))
        day17.OUT(v) -> {
          let new_output = [out(reg, v), ..output]
          Ok(build_program_state(reg, p + 2, new_output))
        }
      }
  }
}

/// Run until the program halts, returning the final machine state.
pub fn run_program(
  state: day17.ProgramState,
  instructions: InstructionSet,
) -> day17.ProgramState {
  case next(state, instructions) {
    Error(_) -> state
    Ok(next_state) -> run_program(next_state, instructions)
  }
}

/// Execute the input program and return the comma-separated output required by
/// the puzzle description.
pub fn solve(input: Input) -> Output {
  use #(initial_state, raw_instructions) <- result.try(input)
  let instruction_set = instruction_set_from_raw(raw_instructions)
  let final_state = run_program(initial_state, instruction_set)
  let result =
    final_state.output
    |> list.reverse
    |> list.map(int.to_string)
    |> string.join(",")
  Ok(result)
}

pub fn main() -> Output {
  day17.input_path |> parse.read_input |> solve |> echo
}
