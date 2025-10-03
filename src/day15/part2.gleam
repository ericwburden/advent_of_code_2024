import common/grid2d
import day15/day15.{
  type Direction, type DoubleTile, type Input, type Output, type Tile, Box,
  DoubleRobot, DoubleWall, LeftBox, RightBox, Robot, Wall, double_tile_to_char,
  render_grid,
}
import day15/parse
import day15/part1.{gps_coordinate, move_tile, to_offset}
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/set

/// We're going to need to expand our grid horizontally, which means we need to
/// expand each tile individually. Since they're all handled a little
/// differently, we use this function to take an entry from the original
/// grid2d.Grid2D(Tile) and convert it to an entry for a 
/// grid2d.Grid2D(DoubleTile), expanding the column indices as necessary.
fn tile_to_double_entries(
  tile_entry: #(grid2d.Index2D, Tile),
) -> List(#(grid2d.Index2D, DoubleTile)) {
  let #(grid2d.Index2D(row, col), tile) = tile_entry
  case tile {
    Wall -> [
      #(grid2d.Index2D(row, col * 2), DoubleWall),
      #(grid2d.Index2D(row, col * 2 + 1), DoubleWall),
    ]
    Robot -> [#(grid2d.Index2D(row, col * 2), DoubleRobot)]
    Box -> [
      #(grid2d.Index2D(row, col * 2), LeftBox),
      #(grid2d.Index2D(row, col * 2 + 1), RightBox),
    ]
  }
}

/// Maps over a grid2d.Grid2D(Tile) and converts it to a 
/// grid2d.Grid2D(DoubleTile).
fn to_double_grid(grid: grid2d.Grid2D(Tile)) -> grid2d.Grid2D(DoubleTile) {
  grid
  |> dict.to_list
  |> list.flat_map(tile_to_double_entries)
  |> dict.from_list
}

/// Given either side of a box and its index, return the ordered pair of
/// indices for both sides of the box, #(left_index, right_index).
fn to_whole_box(
  index: grid2d.Index2D,
  tile: DoubleTile,
) -> #(grid2d.Index2D, grid2d.Index2D) {
  let grid2d.Index2D(row, col) = index
  case tile {
    LeftBox -> #(index, grid2d.Index2D(row, col + 1))
    RightBox -> #(grid2d.Index2D(row, col - 1), index)
    _ -> #(index, index)
  }
}

/// Entry point when the robot bumps into a box tile. We figure out whether we
/// hit the left or right half, convert that tile into the full pair, and hand
/// off to `try_to_push_box_go` to do the heavy lifting. If the tile was not a
/// box we return an Error(Nil).
fn try_to_push_whole_box(
  grid: grid2d.Grid2D(DoubleTile),
  box_at: grid2d.Index2D,
  direction: Direction,
) -> Result(grid2d.Grid2D(DoubleTile), Nil) {
  let whole_box_result = case dict.get(grid, box_at) {
    Ok(LeftBox) -> Ok(to_whole_box(box_at, LeftBox))
    Ok(RightBox) -> Ok(to_whole_box(box_at, RightBox))
    _ -> Error(Nil)
  }
  use new_box <- result.try(whole_box_result)
  try_to_push_whole_box_go(grid, new_box, direction, set.new())
}

/// Handles the work of pushing a full horizontal box pair in the given
/// direction. It walks any blocking boxes depth-first and finally replaces the
/// original tiles with their new positions. The return value is the updated
/// grid or an error if the push is blocked.
fn try_to_push_whole_box_go(
  grid: grid2d.Grid2D(DoubleTile),
  whole_box: #(grid2d.Index2D, grid2d.Index2D),
  direction: Direction,
  boxes_already_pushed: set.Set(#(grid2d.Index2D, grid2d.Index2D)),
) -> Result(grid2d.Grid2D(DoubleTile), Nil) {
  case set.contains(boxes_already_pushed, whole_box) {
    True -> Ok(grid)
    False -> {
      let already_pushed = set.insert(boxes_already_pushed, whole_box)

      let #(prev_left, prev_right) = whole_box
      let next_left = grid2d.apply_offset(prev_left, to_offset(direction))
      let next_right = grid2d.apply_offset(prev_right, to_offset(direction))

      // Inspect the tile directly ahead of one half of the box. If something
      // blocks the way, we recurse before moving this pair; otherwise we let
      // the push continue unchanged.
      let try_push = fn(current_grid, half_box) {
        // Skip the tiles belonging to the box we're already moving so we
        // don't recurse into the same pair and loop forever.
        case half_box == prev_left || half_box == prev_right {
          True -> Ok(current_grid)
          False ->
            try_to_push_single_tile_go(
              current_grid,
              direction,
              already_pushed,
              half_box,
            )
        }
      }

      // Because the box occupies two tiles, push the left half and then the
      // right. If either step fails, the whole chain aborts.
      use grid_try_left <- result.try(try_push(grid, next_left))
      use grid_try_both <- result.try(try_push(grid_try_left, next_right))

      // If both succeed, every dependent push has already completed so we can
      // update the grid to reflect this box's new location.
      let grid_with_box_moved =
        grid_try_both
        |> dict.delete(prev_left)
        |> dict.delete(prev_right)
        |> dict.insert(next_left, LeftBox)
        |> dict.insert(next_right, RightBox)

      Ok(grid_with_box_moved)
    }
  }
}

/// Handles the per-tile checks used by `try_to_push_whole_box_go`. Each half of
/// the box calls into this helper so we can resolve what sits in front of it:
/// walls block, box halves recurse on the full box, and clear spaces allow the
/// push to proceed unchanged.
fn try_to_push_single_tile_go(
  grid: grid2d.Grid2D(DoubleTile),
  direction: Direction,
  boxes_already_pushed: set.Set(#(grid2d.Index2D, grid2d.Index2D)),
  single_tile: grid2d.Index2D,
) {
  case dict.get(grid, single_tile) {
    // If we're pushing against a wall, stop. No movement occurs.
    Ok(DoubleWall) -> Error(Nil)

    // If we're pushing a half box, then put it together with its other half
    // and push the whole box.
    Ok(LeftBox) -> {
      let whole_box = to_whole_box(single_tile, LeftBox)
      try_to_push_whole_box_go(grid, whole_box, direction, boxes_already_pushed)
    }
    Ok(RightBox) -> {
      let whole_box = to_whole_box(single_tile, RightBox)
      try_to_push_whole_box_go(grid, whole_box, direction, boxes_already_pushed)
    }

    // Otherwise the space is clear, so return success without changing the grid.
    _ -> Ok(grid)
  }
}

/// With all the logic in place for handling boxes, it's now time to move the
/// robot itself. This is probably the easy part.
fn move_robot(
  grid: grid2d.Grid2D(DoubleTile),
  robot: grid2d.Index2D,
  direction: Direction,
) -> #(grid2d.Grid2D(DoubleTile), grid2d.Index2D) {
  // Same as part 1, check the next space we want our robot to move into
  let next = grid2d.apply_offset(robot, to_offset(direction))
  case dict.get(grid, next) {
    // If it's a wall, do nothing and return the grid and robot unchanged
    Ok(DoubleWall) -> #(grid, robot)

    // If it's either of the two types of boxes, we try to push the box. If
    // the box moves, update the grid and robot position. If it doesn't move,
    // because it's blocked by a wall, then nothing happens.
    Ok(LeftBox) ->
      case try_to_push_whole_box(grid, next, direction) {
        Ok(next_grid) -> #(move_tile(next_grid, robot, next, DoubleRobot), next)
        Error(_) -> #(grid, robot)
      }
    Ok(RightBox) ->
      case try_to_push_whole_box(grid, next, direction) {
        Ok(next_grid) -> #(move_tile(next_grid, robot, next, DoubleRobot), next)
        Error(_) -> #(grid, robot)
      }

    // For an empty space, we just move the robot without needing to check
    // anything else. We explicitly don't check for other robots, because we
    // know there is only one.
    _ -> #(move_tile(grid, robot, next, DoubleRobot), next)
  }
}

/// For Part 2, we simulate the movements of an out-of-control package-shifting
/// robot around a warehouse. Except now, it's a double-wide! Well, actually,
/// the robot is the same size, it's just the boxes that are double-wide. So,
/// we have to double the grid and adjust the robot location to the shiny, new,
/// wider layout before we start it to crashing around.
pub fn solve(input: Input) -> Output {
  use #(grid, robot, directions) <- result.try(input)

  // Widen the grid and re-place the robot.
  let double_grid = to_double_grid(grid)
  let double_robot = grid2d.Index2D(robot.row, robot.col * 2)

  // Walk through the given directions, shoving boxes as needed and able.
  let #(final_grid, _) =
    list.fold(directions, #(double_grid, double_robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

  // Sum the GPS coordinates of the left side of each wide box.
  let gps_sum =
    dict.fold(final_grid, 0, fn(acc, index, tile) {
      case tile {
        LeftBox -> acc + gps_coordinate(index)
        _ -> acc
      }
    })

  Ok(gps_sum)
}

pub fn main() -> Nil {
  let parse_input_result = day15.example2_path |> parse.read_input
  let assert Ok(#(grid, robot, directions)) = parse_input_result

  let double_grid = to_double_grid(grid)
  let double_robot = grid2d.Index2D(robot.row, robot.col * 2)

  render_grid(double_grid, double_tile_to_char) |> io.println

  let #(final_grid, _) =
    list.fold(directions, #(double_grid, double_robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

  render_grid(final_grid, double_tile_to_char) |> io.println
}
