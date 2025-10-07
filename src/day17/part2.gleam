import day17/day17.{type Input, type Output}
import day17/parse
import day17/part1.{run_program}
import gleam/int
import gleam/list
import gleam/result

fn set_register(
  state: day17.ProgramState,
  register: day17.RegisterName,
  value: Int,
) -> day17.ProgramState {
  let updated_registers = case register {
    day17.A ->
      day17.Registers(a: value, b: state.registers.b, c: state.registers.c)
    day17.B ->
      day17.Registers(a: state.registers.a, b: value, c: state.registers.c)
    day17.C ->
      day17.Registers(a: state.registers.a, b: state.registers.b, c: value)
  }
  day17.ProgramState(
    updated_registers,
    state.instruction_pointer,
    state.instructions,
    state.output,
  )
}

fn find_next_a_registers(
  program_state: day17.ProgramState,
  target_output: Int,
) -> List(Int) {
  let last_a_register = program_state.registers.a
  list.filter_map(list.range(0, 7), fn(n) {
    let test_a_register =
      int.bitwise_or(int.bitwise_shift_left(last_a_register, 3), n)
    let test_initial_state =
      set_register(program_state, day17.A, test_a_register)
    let test_final_state = run_program(test_initial_state)
    case list.reverse(test_final_state.output) {
      [output, ..] if output == target_output -> Ok(test_a_register)
      _ -> Error(Nil)
    }
  })
}

pub fn solve(input: Input) -> Output {
  use initial_state <- result.try(input)

  list.fold(
    list.reverse([0, 3, 5, 4, 3, 0]),
    // list.reverse([2, 4, 1, 2, 7, 5, 4, 5, 1, 3, 5, 5, 0, 3, 3, 0]),
    [0],
    fn(acc, n) {
      list.flat_map(acc, fn(last_register_a) {
        initial_state
        |> set_register(day17.A, last_register_a)
        |> find_next_a_registers(n)
      })
    },
  )
  |> list.reduce(int.min)
  |> result.map(int.to_string)
  |> result.map_error(fn(_) {
    "Could not find an A register value to produce the instructions!"
  })
}

pub fn main() -> Output {
  day17.example2_path |> parse.read_input |> solve |> echo
}
