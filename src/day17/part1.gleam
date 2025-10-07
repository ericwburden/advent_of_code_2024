import day17/day17.{type Input, type InstructionSet, type Output}
import day17/parse
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Convert the raw opcode/operand pairs into the strongly typed instructions
/// defined in `day17.gleam`. This isn't 1000% necessary, but I find it really
/// helpful when debugging to check instructions by name instead of by number.
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

/// Build the instruction set dictionary keyed by instruction pointer. Since
/// lists in Gleam are all linked lists, meaning you can just index into a
/// specific position, it made the most sense to me to use a Dict where
/// the key is the instruction index. It probably doesn't make a ton of
/// difference performance-wise, since the lists of instructions are so short,
/// but I like it better this way.
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
/// Returns the literal value for values 0 -> 3 and register values for 4, 
/// 5, and 6.
fn combo_operand_value(registers: day17.Registers, operand: Int) -> Int {
  case operand {
    4 -> registers.a
    5 -> registers.b
    6 -> registers.c
    _ -> operand
  }
}

/// Implementations for each opcode follow, mutating the target register(s) as
/// specified by the puzzle. I won't re-state the puzzle text here, just note
/// that most operations modify the program registers, but `jnz` modifies the
/// pointer direction and `out` returns an output value.
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

fn bxc(registers: day17.Registers) -> day17.Registers {
  let new_b = int.bitwise_exclusive_or(registers.b, registers.c)
  day17.Registers(registers.a, new_b, registers.c)
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

fn jnz(registers: day17.Registers, operand: Int, pointer: Int) -> Int {
  case registers.a == 0 {
    True -> pointer + 2
    False -> operand
  }
}

fn out(registers: day17.Registers, operand: Int) -> Int {
  let op_val = combo_operand_value(registers, operand)
  int.bitwise_and(op_val, 7)
}

/// Advance the VM by executing the instruction at the current pointer. Returns
/// an updated state of the program after running the instruction with the
/// index of `state.instruction_pointer`. Returns an error if the program is
/// halted because the pointer is outside the range of instructions.
pub fn next(
  state: day17.ProgramState,
  instructions: InstructionSet,
) -> Result(day17.ProgramState, Nil) {
  // Shorthands for the components of the program state, just to help
  // condense this function for readability.
  let day17.ProgramState(reg, p, output) = state
  case dict.get(instructions, p) {
    Error(Nil) -> Error(Nil)
    Ok(instruction) ->
      case instruction {
        day17.ADV(v) -> Ok(day17.ProgramState(adv(reg, v), p + 2, output))
        day17.BDV(v) -> Ok(day17.ProgramState(bdv(reg, v), p + 2, output))
        day17.BST(v) -> Ok(day17.ProgramState(bst(reg, v), p + 2, output))
        day17.BXC -> Ok(day17.ProgramState(bxc(reg), p + 2, output))
        day17.BXL(v) -> Ok(day17.ProgramState(bxl(reg, v), p + 2, output))
        day17.CDV(v) -> Ok(day17.ProgramState(cdv(reg, v), p + 2, output))
        day17.JNZ(v) -> Ok(day17.ProgramState(reg, jnz(reg, v, p), output))
        day17.OUT(v) -> {
          let new_output = [out(reg, v), ..output]
          Ok(day17.ProgramState(reg, p + 2, new_output))
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

/// Part 1 just requires that we take the program state as given and run the
/// instructions until the program halts, reporting the output as a
/// comma-separated string of output values. Seems like an odd choice, given
/// our results are usually numeric, but it's what the puzzle demands!
pub fn solve(input: Input) -> Output {
  use #(initial_state, raw_instructions) <- result.try(input)

  // Parse the instructions
  let instruction_set = instruction_set_from_raw(raw_instructions)

  // Run the program
  let final_state = run_program(initial_state, instruction_set)

  // We need to reverse the output list since the output gets built in reverse
  // order because that's how linked lists do.
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
