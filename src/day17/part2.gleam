import day17/day17.{type Input, type InstructionSet, type Output}
import day17/parse
import day17/part1.{instruction_set_from_raw}
import gleam/int
import gleam/list
import gleam/result

/// Overwrite register A while leaving the rest of the program state untouched.
fn set_a_register(state: day17.ProgramState, a: Int) -> day17.ProgramState {
  let day17.ProgramState(registers, instruction_pointer, output) = state
  let day17.Registers(_, b, c) = registers
  let updated_registers = day17.Registers(a: a, b: b, c: c)
  day17.ProgramState(updated_registers, instruction_pointer, output)
}

/// Run the program until it produces its first output value. This will be
/// super handy for testing what output we can expect from a given A 
/// register value.
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

/// This is where parsing the instructions into something a bit more human
/// readable really came in handy. Your mileage may vary, but here's what
/// my program does:
/// 
///  0 - bst(4) - A & 7  -> B
///  2 - bxl(2) - B ^ 2  -> B
///  4 - cdv(5) - A >> B -> C
///  6 - bxc    - B ^ C  -> B
///  8 - bxl(3) - B ^ 3  -> B
/// 10 - out(5) - output B
/// 12 - adv(3) - A >> 3 -> A
/// 14 - jnz(0) - exit if A == 0, else restart
/// 
/// If you squint at it long enough, you'll realize, like I did, that the
/// output from each round of execution is dependent on the last 7 bits of
/// whatever is in register A and that the values of register B and C are
/// entirely dependent on the value of A at the start of the loop. *However*, 
/// we can narrow this down further by essentially executing the program in 
/// reverse, which is what this function helps us do. 
/// 
/// In order to find the list of valid A-register values that will produce, as
/// the next output, the `target_output`, we shift the value of the current
/// A-register left by three bits and then iterate through all 8 possible 
/// combinations of setting the bottom three bits (0 -7). We save off every
/// modified A-register value that will produce the `target_output` and return
/// that list.
fn find_next_a_registers(
  program_state: day17.ProgramState,
  instructions: InstructionSet,
  target_output: Int,
) -> List(Int) {
  let last_a_register = program_state.registers.a
  list.filter_map(list.range(0, 7), fn(candidate_digit) {
    // Create a new A-register value to test by shifting the old A-register
    // left by 3 bits and replacing the bottom 3 bits with `candidate_digit`.
    let candidate_register =
      int.bitwise_or(
        int.bitwise_shift_left(last_a_register, 3),
        candidate_digit,
      )

    // Then we set the A-register and check the first output value from the
    // program. If it matches the `target_output`, we'll keep it.
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

  // We'll run this function for each of the values in the raw program
  // instructions, in reverse. The accumulator is the list of A-register values
  // that produced the last `expected_output`. The final result will be the
  // list of all A-register values that retain the bits of the last A-register
  // values, shifted left by 3 bits, and modified to produce the current 
  // `expected_output`. There are only 8-possible modifications for each
  // previous value (append 0-7).
  let extend_candidates = fn(acc: List(Int), expected_output: Int) -> List(Int) {
    // For every surviving prefix, try appending each possible digit and keep
    // only those that match the next output value.
    list.flat_map(acc, fn(previous_register_a) {
      initial_state
      |> set_a_register(previous_register_a)
      |> find_next_a_registers(instructions, expected_output)
    })
  }

  // For each value from the original raw instructions, in reverse order, find
  // all the A-register values that can produce that instruction value, in
  // sequence. We reverse the order here to essentially run the program
  // backwards, since the last output value only depends on the top three
  // bits of the original A-register, the second-to-last output value depends
  // on the top six bits, and so on.
  list.fold(list.reverse(raw_instructions), [0], extend_candidates)
  |> list.reduce(int.min)
  |> result.map(int.to_string)
  |> result.map_error(fn(_) {
    "Could not find an A register value to re-produce the instructions!"
  })
}

pub fn main() -> Output {
  day17.example2_path |> parse.read_input |> solve |> echo
}
