import day17/day17.{type Input, type InstructionSet, type Output}
import day17/parse
import day17/part1.{instruction_set_from_raw}
import gleam/int
import gleam/list
import gleam/result

/// Overwrite register A while leaving the rest of the program state untouched.
fn set_a_register(state: day17.ProgramState, value: Int) -> day17.ProgramState {
  let day17.ProgramState(registers, instruction_pointer, output) = state
  let day17.Registers(_, b, c) = registers
  let updated_registers = day17.Registers(a: value, b: b, c: c)

  day17.ProgramState(
    registers: updated_registers,
    instruction_pointer: instruction_pointer,
    output: output,
  )
}

/// Step the VM until the first output value is produced.
pub fn first_output(
  state: day17.ProgramState,
  instructions: InstructionSet,
) -> Result(Int, Nil) {
  case state.output {
    [] -> {
      let try_next_state =
        part1.next(state, instructions)
        |> result.map_error(fn(_) { Nil })
      use next_state <- result.try(try_next_state)
      first_output(next_state, instructions)
    }
    [value] -> Ok(value)
    _ -> Error(Nil)
  }
}

/// Given the current prefix of register-A bits, enumerate which children keep
/// the program on track for the expected output digit.
fn find_next_a_registers(
  program_state: day17.ProgramState,
  instructions: InstructionSet,
  target_output: Int,
) -> List(Int) {
  let last_a_register = program_state.registers.a
  list.filter_map(list.range(0, 7), fn(candidate_digit) {
    let candidate_register =
      int.bitwise_or(int.bitwise_shift_left(last_a_register, 3), candidate_digit)
    let test_initial_state = set_a_register(program_state, candidate_register)
    case first_output(test_initial_state, instructions) {
      Ok(output) if output == target_output -> Ok(candidate_register)
      _ -> Error(Nil)
    }
  })
}

/// Search for the smallest register-A seed that reproduces the whole program
/// output stream by iteratively building valid prefixes.
pub fn solve(input: Input) -> Output {
  use #(initial_state, raw_instructions) <- result.try(input)
  let instructions = instruction_set_from_raw(raw_instructions)

  let extend_candidates = fn(candidates: List(Int), expected_output: Int) -> List(Int) {
    // For every surviving prefix, try appending each possible digit and keep
    // only those that match the next output value.
    list.flat_map(candidates, fn(previous_register_a) {
      initial_state
      |> set_a_register(previous_register_a)
      |> find_next_a_registers(instructions, expected_output)
    })
  }

  list.fold(list.reverse(raw_instructions), [0], extend_candidates)
  |> list.reduce(int.min)
  |> result.map(int.to_string)
  |> result.map_error(fn(_) {
    "Could not find an A register value to produce the instructions!"
  })
}

pub fn main() -> Output {
  day17.example2_path |> parse.read_input |> solve |> echo
}
