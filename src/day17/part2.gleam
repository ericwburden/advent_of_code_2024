import day17/day17.{type Input, type InstructionSet, type Output}
import day17/parse
import day17/part1.{instruction_set_from_raw}
import gleam/int
import gleam/list
import gleam/result

fn set_a_register(state: day17.ProgramState, value: Int) -> day17.ProgramState {
  let updated_registers =
    day17.Registers(a: value, b: state.registers.b, c: state.registers.c)
  day17.ProgramState(
    registers: updated_registers,
    instruction_pointer: state.instruction_pointer,
    output: state.output,
  )
}

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

fn find_next_a_registers(
  program_state: day17.ProgramState,
  instructions: InstructionSet,
  target_output: Int,
) -> List(Int) {
  let last_a_register = program_state.registers.a
  list.filter_map(list.range(0, 7), fn(n) {
    let test_a_register =
      int.bitwise_or(int.bitwise_shift_left(last_a_register, 3), n)
    let test_initial_state = set_a_register(program_state, test_a_register)
    case first_output(test_initial_state, instructions) {
      Ok(x) if x == target_output -> Ok(test_a_register)
      _ -> Error(Nil)
    }
  })
}

pub fn solve(input: Input) -> Output {
  use #(initial_state, raw_instructions) <- result.try(input)
  let instructions = instruction_set_from_raw(raw_instructions)

  list.fold(list.reverse(raw_instructions), [0], fn(acc, n) {
    list.flat_map(acc, fn(last_register_a) {
      initial_state
      |> set_a_register(last_register_a)
      |> find_next_a_registers(instructions, n)
    })
  })
  |> list.reduce(int.min)
  |> result.map(int.to_string)
  |> result.map_error(fn(_) {
    "Could not find an A register value to produce the instructions!"
  })
}

pub fn main() -> Output {
  day17.example2_path |> parse.read_input |> solve |> echo
}
