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

fn apply_direction(
  index: grid2d.Index2D,
  direction: Direction,
) -> grid2d.Index2D {
  let grid2d.Index2D(row, col) = index

  case direction {
    Up -> grid2d.Index2D(row - 1, col)
    Down -> grid2d.Index2D(row + 1, col)
    Left -> grid2d.Index2D(row, col - 1)
    Right -> grid2d.Index2D(row, col + 1)
  }
}

pub fn move_robot(
  grid: grid2d.Grid2D(Tile),
  robot: grid2d.Index2D,
  direction: Direction,
) -> #(grid2d.Grid2D(Tile), grid2d.Index2D) {
  let next = apply_direction(robot, direction)

  case grid2d.get(grid, next) {
    Ok(Wall) -> #(grid, robot)
    Ok(Box) -> push_and_move_robot(grid, robot, next, direction)
    Ok(_) -> #(set_robot_position(grid, robot, next), next)
    Error(_) -> #(set_robot_position(grid, robot, next), next)
  }
}

fn set_robot_position(
  grid: grid2d.Grid2D(Tile),
  from: grid2d.Index2D,
  to: grid2d.Index2D,
) -> grid2d.Grid2D(Tile) {
  grid
  |> dict.delete(from)
  |> dict.insert(to, Robot)
}

fn push_and_move_robot(
  grid: grid2d.Grid2D(Tile),
  robot: grid2d.Index2D,
  box_index: grid2d.Index2D,
  direction: Direction,
) -> #(grid2d.Grid2D(Tile), grid2d.Index2D) {
  case push_boxes(grid, box_index, direction) {
    Ok(grid_after_push) -> {
      let updated_grid = set_robot_position(grid_after_push, robot, box_index)
      #(updated_grid, box_index)
    }

    Error(_) -> #(grid, robot)
  }
}

fn push_boxes(
  grid: grid2d.Grid2D(Tile),
  index: grid2d.Index2D,
  direction: Direction,
) -> Result(grid2d.Grid2D(Tile), Nil) {
  let next = apply_direction(index, direction)

  case grid2d.get(grid, next) {
    Ok(Wall) -> Error(Nil)
    Ok(Box) ->
      case push_boxes(grid, next, direction) {
        Ok(grid_after_push) ->
          Ok(grid_after_push |> dict.delete(index) |> dict.insert(next, Box))

        Error(_) -> Error(Nil)
      }

    Ok(_) -> Ok(grid |> dict.delete(index) |> dict.insert(next, Box))
    Error(_) -> Ok(grid |> dict.delete(index) |> dict.insert(next, Box))
  }
}

fn gps_coordinate(location: grid2d.Index2D) -> Int {
  let grid2d.Index2D(row, col) = location
  { row * 100 } + col
}

pub fn solve(input: Input) -> Output {
  use #(grid, robot, directions) <- result.try(input)
  let #(final_grid, _) =
    list.fold(directions, #(grid, robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

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
