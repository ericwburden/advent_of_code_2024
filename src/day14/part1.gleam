import common/grid2d
import day14/day14.{type Input, type Output, type Robot, Robot}
import day14/parse
import gleam/list
import gleam/result

/// A snapshot of the warehouse floor: how wide it is, how tall it is, and
/// a list of all the robots in their current state.
pub type Floor {
  Floor(width: Int, height: Int, robots: List(Robot))
}

/// Nudges a single robot forward by one second, wrapping them around the
/// edges because apparently they can teleport sometimes.
fn move_robot(width: Int, height: Int, robot: Robot) -> Robot {
  let Robot(position: position, velocity: velocity) = robot
  let grid2d.Index2D(row, col) = grid2d.apply_offset(position, velocity)
  let new_row = { { row % height } + height } % height
  let new_col = { { col % width } + width } % width

  Robot(position: grid2d.Index2D(new_row, new_col), velocity: velocity)
}

/// Marches every robot forward by one second, returning the state of the floor
/// after every robot has moved.
pub fn move_all_robots(floor: Floor) -> Floor {
  let Floor(width, height, robots) = floor
  let moved = list.map(robots, fn(robot) { move_robot(width, height, robot) })
  Floor(width, height, moved)
}

/// Runs the clock forward `seconds` ticks by repeatedly moving the robots.
pub fn move_for_seconds(floor: Floor, seconds: Int) -> Floor {
  case seconds {
    0 -> floor
    _ -> move_for_seconds(move_all_robots(floor), seconds - 1)
  }
}

/// Counts how many robots are in each quadrant of the grid is (ignoring the 
/// middle row and column) and multiplies the four counts together. Lower 
/// numbers usually mean the robots are huddled together in an interesting 
/// pattern (obvious foreshadowing...).
pub fn calculate_safety_factor(floor: Floor) -> Int {
  let mid_row = floor.height / 2
  let mid_col = floor.width / 2

  // We're going to fold over the list of robots, keeping track of the counts
  // in each quadrant separately.
  let #(top_left, top_right, bottom_left, bottom_right) =
    list.fold(floor.robots, #(0, 0, 0, 0), fn(acc, robot) {
      let #(tl, tr, bl, br) = acc
      let Robot(position: position, velocity: _) = robot
      let grid2d.Index2D(row, col) = position

      // To assign the current robot to a quadrant, we need to compare its
      // location to the middle row and middle column.
      case row < mid_row, row > mid_row, col < mid_col, col > mid_col {
        // Above and to the left of the center point
        True, False, True, False -> #(tl + 1, tr, bl, br)

        // Above and to the right of the center point
        True, False, False, True -> #(tl, tr + 1, bl, br)

        // Below and to the left of the center point
        False, True, True, False -> #(tl, tr, bl + 1, br)

        // Below and to the right of the center point
        False, True, False, True -> #(tl, tr, bl, br + 1)

        // Literally anywhere else and we ignore it. Realistically, this will
        // just skip the robots that lie on the middle row or middle column.
        _, _, _, _ -> acc
      }
    })

  // Safety factor is the counts for all four quadrants multiplied together.
  top_left * top_right * bottom_left * bottom_right
}

/// The Part 1 answer: move the robots 100 seconds into the future and report
/// the resulting safety factor. Pretty straightforward simulation.
pub fn solve(input: Input, floor_width: Int, floor_height: Int) -> Output {
  use robots <- result.try(input)

  let floor = Floor(floor_width, floor_height, robots)
  let final_state = move_for_seconds(floor, 100)
  let safety_factor = calculate_safety_factor(final_state)

  Ok(safety_factor)
}

/// Sanity check
pub fn main() {
  let assert Ok(robots) = day14.input_path |> parse.read_input
  let floor = Floor(101, 103, robots)
  let final_state = move_for_seconds(floor, 100)
  echo calculate_safety_factor(final_state)
}
