import common/grid2d
import day14/day14.{type Input, type Output, type Robot}
import day14/parse
import day14/part1.{type Floor, Floor, calculate_safety_factor, move_all_robots}
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

/// Part 2 asks us to check for a tree without actually telling us what the
/// tree is supposed to look like. So, I decided to just go with what I
/// thought a minimal tree _might_ look like and see if that worked. My
/// minimal tree shape is:
/// 
/// ...........
/// .....#.....
/// ....###....
/// ...#####...
/// ..#######..
/// .....#.....
/// .....#.....
/// .....#.....
/// .....#.....
/// ...........
/// 
/// Wonder of wonders, it actually works! Checking for this shape is actually
/// slower than what I suspect the intended solution was, but it works!
const minimal_tree_offsets = [
  // The tip of the triangle
  grid2d.Offset2D(0, 0),

  // The row of the triangle
  grid2d.Offset2D(-1, 1),
  grid2d.Offset2D(0, 1),
  grid2d.Offset2D(1, 1),

  // The third row of the triangle
  grid2d.Offset2D(-2, 2),
  grid2d.Offset2D(-1, 2),
  grid2d.Offset2D(0, 2),
  grid2d.Offset2D(1, 2),
  grid2d.Offset2D(2, 2),

  // The fourth row of the triangle
  grid2d.Offset2D(-3, 3),
  grid2d.Offset2D(-2, 3),
  grid2d.Offset2D(-1, 3),
  grid2d.Offset2D(0, 3),
  grid2d.Offset2D(1, 3),
  grid2d.Offset2D(2, 3),
  grid2d.Offset2D(3, 3),

  // A column exending downwards from the middle, to make it a little more
  // tree-shaped
  grid2d.Offset2D(0, 5),
  grid2d.Offset2D(0, 6),
  grid2d.Offset2D(0, 7),
  grid2d.Offset2D(0, 8),
]

/// Given a position on the floor and a set of all the robot positions,
/// determine whether the given robot is at the tip top of our minimal
/// tree representation.
fn is_minimal_tree_at(
  robot_positions: set.Set(grid2d.Index2D),
  tip: grid2d.Index2D,
) -> Bool {
  list.all(minimal_tree_offsets, fn(offset) {
    set.contains(robot_positions, grid2d.apply_offset(tip, offset))
  })
}

/// It's possible that there could be more than one minimal tree pattern at
/// any given time. To that end, we check through our list of robot positions
/// until we find at least one for a given time period.
pub fn any_minimal_tree_pattern(robots: List(Robot)) -> Bool {
  let robot_positions =
    robots
    |> list.map(fn(robot) { robot.position })
    |> set.from_list

  list.any(robots, fn(robot) {
    is_minimal_tree_at(robot_positions, robot.position)
  })
}

/// It's also possible that our minimal tree could show up at multiple times,
/// which would at least narrow down the number of floor renders we'd need to
/// eyeball to figure out if there's a full tree there (and update our
/// representation to test for). So, we advance the floor state an absurdly
/// large number of times, checking for the minimal tree at each step, and
/// return the list of times at which we found it.
pub fn find_minimal_tree_times(floor: Floor) -> List(Int) {
  case floor.width <= 0 || floor.height <= 0 {
    True -> []
    False -> {
      // The absurdly large number of seconds to check for
      let period = floor.width * floor.height

      let #(found_times, _) =
        list.fold(list.range(0, period - 1), #([], floor), fn(acc, second) {
          let #(found_times, current_floor) = acc
          let found_times = case
            any_minimal_tree_pattern(current_floor.robots)
          {
            False -> found_times
            True -> [second, ..found_times]
          }
          let next_floor = move_all_robots(current_floor)
          #(found_times, next_floor)
        })

      found_times
    }
  }
}

/// So, through a bit of thinking, testing, and reading other people's
/// thoughts, it turns out that the intended solution was probably to check
/// for the time with the lowest safety factor, because, of course it is. It
/// seems so obvious in hind-sight. This check actually runs faster than my
/// foray into spot checking for partial tree shapes, but I was able to confirm
/// that, for my input at least, both approaches give the same answer.
pub fn find_lowest_safety_second(floor: Floor) -> Int {
  case floor.width <= 0 || floor.height <= 0 {
    True -> 0
    False -> {
      let period = floor.width * floor.height
      let initial_safety = calculate_safety_factor(floor)

      let #(best_second, _, _) =
        list.fold(
          list.range(1, period),
          #(0, initial_safety, floor),
          fn(acc, second) {
            let #(best_second, best_safety, current) = acc
            let next_state = move_all_robots(current)
            let next_safety = calculate_safety_factor(next_state)

            case next_safety < best_safety {
              True -> #(second, next_safety, next_state)
              False -> #(best_second, best_safety, next_state)
            }
          },
        )

      best_second
    }
  }
}

pub fn solve(input: Input, floor_width: Int, floor_height: Int) -> Output {
  use robots <- result.try(input)

  let floor = Floor(floor_width, floor_height, robots)
  let target_time = find_lowest_safety_second(floor)

  Ok(target_time)
}

// I'm going to leave this here. This main function can be used to confirm
// that, indeed, finding the lowest safety value coincides with finding a
// tree pattern in the robots.
pub fn main() {
  let assert Ok(robots) = day14.input_path |> parse.read_input
  let floor = Floor(101, 103, robots)
  let target_time = find_lowest_safety_second(floor)
  let assert [tree_time] = find_minimal_tree_times(floor)
  assert target_time == tree_time
}

/// Because I needed to print the dang floor pattern and make sure I was
/// getting a tree! Also, I wanted to see the tree.
pub fn render_robot_grid(width: Int, height: Int, robots: List(Robot)) -> String {
  case width <= 0 || height <= 0 {
    True -> ""
    False -> {
      let robot_positions =
        robots
        |> list.map(fn(robot) { robot.position })
        |> set.from_list

      list.range(0, height - 1)
      |> list.map(fn(row) {
        list.range(0, width - 1)
        |> list.map(fn(col) {
          let position = grid2d.Index2D(row, col)
          case set.contains(robot_positions, position) {
            True -> "#"
            False -> "."
          }
        })
        |> string.join("")
      })
      |> string.join("\n")
    }
  }
}

pub fn print_robot_grid(width: Int, height: Int, robots: List(Robot)) -> Nil {
  render_robot_grid(width, height, robots) |> io.println
}
