import common/grid2d
import day15/day15.{
  type Direction, type Input, type Output, type Tile, Box, Down, Left, Right,
  Robot, Up, Wall, render_grid, tile_to_char,
}
import day15/parse
import gleam/dict
import gleam/io
import gleam/list
import gleam/result

/// Just convert a cardinal direction into the corresponding offset.
pub fn to_offset(direction: Direction) -> grid2d.Offset2D {
  case direction {
    Up -> grid2d.Offset2D(-1, 0)
    Down -> grid2d.Offset2D(1, 0)
    Left -> grid2d.Offset2D(0, -1)
    Right -> grid2d.Offset2D(0, 1)
  }
}

pub fn move_robot(
  grid: grid2d.Grid2D(Tile),
  robot: grid2d.Index2D,
  direction: Direction,
) -> #(grid2d.Grid2D(Tile), grid2d.Index2D) {
  // The next index the robot will move to, assuming it's empty
  let next = grid2d.apply_offset(robot, to_offset(direction))

  case grid2d.get(grid, next) {
    // If we try to move the robot into a wall, just don't
    Ok(Wall) -> #(grid, robot)

    // If we try to move the robot into a box, then we need to try to
    // push that box (or boxes).
    Ok(Box) ->
      case push_boxes(grid, next, direction) {
        // If we succeed in pushing the (potential) row of boxes, then we can
        // slide the robot over.
        Ok(new_grid) -> #(move_tile(new_grid, robot, next, Robot), next)

        // If we can't push the box, then it's just like trying to push a wall.
        Error(_) -> #(grid, robot)
      }

    // Otherwise we're looking at moving the robot into an empty space. In
    // that case, we can just shift them over.
    _ -> #(move_tile(grid, robot, next, Robot), next)
  }
}

/// Handy helper function to move a tile from a given index to a target
/// index.
pub fn move_tile(
  grid: grid2d.Grid2D(a),
  from: grid2d.Index2D,
  to: grid2d.Index2D,
  tile: a,
) -> grid2d.Grid2D(a) {
  grid |> dict.delete(from) |> dict.insert(to, tile)
}

/// You can never assume you're just pushing one box, you have to be prepared
/// to push a whole row of boxes.
fn push_boxes(
  grid: grid2d.Grid2D(Tile),
  box: grid2d.Index2D,
  direction: Direction,
) -> Result(grid2d.Grid2D(Tile), Nil) {
  // Find the index that the box we're currently checking would end up in
  // assuming we can push it.
  let next = grid2d.apply_offset(box, to_offset(direction))

  // Let's see what's in that next index...
  case grid2d.get(grid, next) {
    // If it's a wall, then we're done. We can't push.
    Ok(Wall) -> Error(Nil)

    // If it's another box, then we need to recursively check to see if we
    // can push it. This effectively means that we're following the line of
    // boxes to the end and trying to push the last one. If it moves, then
    // the one before it will move, then the one before that, etc. until we
    // work our way back to the current box.
    Ok(Box) ->
      case push_boxes(grid, next, direction) {
        // If we can push the next box, then we can push this box.
        Ok(new_grid) -> Ok(move_tile(new_grid, box, next, Box))
        // If we can't push the next box, then we can't push this box.
        Error(_) -> Error(Nil)
      }

    // Otherwise, we're trying to push a box into empty space, which we can
    // just do.
    _ -> Ok(move_tile(grid, box, next, Box))
  }
}

/// Calculates the GPS coordinate for a given index.
fn gps_coordinate(location: grid2d.Index2D) -> Int {
  let grid2d.Index2D(row, col) = location
  { row * 100 } + col
}

/// For Part 1, we simulate the movements of an out-of-control package-shifting
/// robot around a warehouse. It's apparently strong enough to push boxes 
/// around, but not strong enough to bust through walls a la Kool-Aid Man.
/// Which, while it would be damaging for the poor lanternfish, would have made
/// this puzzle a lot easier...
pub fn solve(input: Input) -> Output {
  use #(grid, robot, directions) <- result.try(input)

  // We move the robot according to the list of directions we have been given,
  // pushing boxes whenever it encounters them and it can.
  let #(final_grid, _) =
    list.fold(directions, #(grid, robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

  // Once we know what the final configuration of boxes looks like, we can
  // use their positions to calculate the GPS coordinates and sum them.
  let gps_coordinate_sum =
    dict.fold(final_grid, 0, fn(acc, idx, tile) {
      case tile {
        Box -> acc + gps_coordinate(idx)
        _ -> acc
      }
    })

  Ok(gps_coordinate_sum)
}

pub fn main() -> Nil {
  let parse_input_result = day15.example2_path |> parse.read_input
  let assert Ok(#(grid, robot, directions)) = parse_input_result

  render_grid(grid, tile_to_char) |> io.println

  let #(final_grid, _) =
    list.fold(directions, #(grid, robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

  render_grid(final_grid, tile_to_char) |> io.println
}
