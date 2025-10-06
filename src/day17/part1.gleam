import day17/day17.{type Input, type Output}
import day17/parse
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type ErrorType {
  Halted
  InvalidRegister(String)
}

fn combo_operand_value(registers: day17.Registers, operand: Int) -> Int {
  case operand {
    4 -> registers.a
    5 -> registers.b
    6 -> registers.c
    _ -> operand
  }
}

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

pub fn next(state: day17.ProgramState) -> Result(day17.ProgramState, ErrorType) {
  let day17.ProgramState(reg, p, instr, output) = state
  case dict.get(instr, p) {
    Error(Nil) -> Error(Halted)
    Ok(instruction) ->
      case instruction {
        day17.ADV(v) ->
          Ok(day17.ProgramState(adv(reg, v), p + 2, instr, output))
        day17.BDV(v) ->
          Ok(day17.ProgramState(bdv(reg, v), p + 2, instr, output))
        day17.BST(v) ->
          Ok(day17.ProgramState(bst(reg, v), p + 2, instr, output))
        day17.BXC -> Ok(day17.ProgramState(bxc(reg), p + 2, instr, output))
        day17.BXL(v) ->
          Ok(day17.ProgramState(bxl(reg, v), p + 2, instr, output))
        day17.CDV(v) ->
          Ok(day17.ProgramState(cdv(reg, v), p + 2, instr, output))
        day17.JNZ(v) ->
          Ok(day17.ProgramState(reg, jnz(reg, v, p), instr, output))
        day17.OUT(v) ->
          Ok(day17.ProgramState(reg, p + 2, instr, [out(reg, v), ..output]))
      }
  }
}

pub fn run_program(state: day17.ProgramState) -> day17.ProgramState {
  case next(state) {
    Error(_) -> state
    Ok(next_state) -> run_program(next_state)
  }
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let final_state = run_program(input)
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
