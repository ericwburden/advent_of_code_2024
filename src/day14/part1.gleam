import common/grid2d
import day14/day14.{type Input, type Output, type Robot, Robot}
import day14/parse
import gleam/list
import gleam/result

pub type Floor {
  Floor(width: Int, height: Int, robots: List(Robot))
}

fn move_robot(width: Int, height: Int, robot: Robot) -> Robot {
  let Robot(position: position, velocity: velocity) = robot
  let grid2d.Index2D(row, col) = grid2d.apply_offset(position, velocity)
  let new_row = { { row % height } + height } % height
  let new_col = { { col % width } + width } % width

  Robot(position: grid2d.Index2D(new_row, new_col), velocity: velocity)
}

pub fn move_all_robots(floor: Floor) -> Floor {
  let Floor(width, height, robots) = floor
  let moved =
    robots
    |> list.map(fn(robot) { move_robot(width, height, robot) })

  Floor(width, height, moved)
}

pub fn move_for_seconds(floor: Floor, seconds: Int) -> Floor {
  case seconds {
    0 -> floor
    _ -> move_for_seconds(move_all_robots(floor), seconds - 1)
  }
}

pub fn calculate_safety_factor(floor: Floor) -> Int {
  let mid_row = floor.height / 2
  let mid_col = floor.width / 2

  let #(top_left, top_right, bottom_left, bottom_right) =
    list.fold(floor.robots, #(0, 0, 0, 0), fn(acc, robot) {
      let #(tl, tr, bl, br) = acc
      let Robot(position: position, velocity: _) = robot
      let grid2d.Index2D(row, col) = position

      case row < mid_row, row > mid_row, col < mid_col, col > mid_col {
        True, False, True, False -> #(tl + 1, tr, bl, br)
        True, False, False, True -> #(tl, tr + 1, bl, br)
        False, True, True, False -> #(tl, tr, bl + 1, br)
        False, True, False, True -> #(tl, tr, bl, br + 1)
        _, _, _, _ -> acc
      }
    })

  top_left * top_right * bottom_left * bottom_right
}

pub fn solve(input: Input, floor_width: Int, floor_height: Int) -> Output {
  use robots <- result.try(input)

  let floor = Floor(floor_width, floor_height, robots)
  let final_state = move_for_seconds(floor, 100)
  let safety_factor = calculate_safety_factor(final_state)

  Ok(safety_factor)
}

pub fn main() {
  let assert Ok(robots) = day14.input_path |> parse.read_input
  let floor = Floor(101, 103, robots)
  let final_state = move_for_seconds(floor, 100)
  echo calculate_safety_factor(final_state)
}
