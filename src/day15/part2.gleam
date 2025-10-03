import common/grid2d
import day15/day15.{
  type Direction, type DoubleTile, type Input, type Output, type Tile, Box,
  DoubleRobot, DoubleWall, Down, Left, LeftBox, Right, RightBox, Robot, Up, Wall,
  double_tile_to_char, render_grid,
}
import day15/parse
import gleam/dict
import gleam/io
import gleam/list
import gleam/result

fn tile_to_double_entries(
  index: grid2d.Index2D,
  tile: Tile,
) -> List(#(grid2d.Index2D, DoubleTile)) {
  let grid2d.Index2D(row, col) = index
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

pub fn to_double_grid(grid: grid2d.Grid2D(Tile)) -> grid2d.Grid2D(DoubleTile) {
  grid
  |> dict.to_list
  |> list.flat_map(fn(entry) {
    let #(index, tile) = entry
    tile_to_double_entries(index, tile)
  })
  |> dict.from_list
}

fn double_robot_index(robot: grid2d.Index2D) -> grid2d.Index2D {
  let grid2d.Index2D(row, col) = robot
  grid2d.Index2D(row, col * 2)
}

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

fn set_robot_position(
  grid: grid2d.Grid2D(DoubleTile),
  from: grid2d.Index2D,
  to: grid2d.Index2D,
) -> grid2d.Grid2D(DoubleTile) {
  grid
  |> dict.delete(from)
  |> dict.insert(to, DoubleRobot)
}

fn normalize_pair(
  left: grid2d.Index2D,
  right: grid2d.Index2D,
) -> #(grid2d.Index2D, grid2d.Index2D) {
  let grid2d.Index2D(_, left_col) = left
  let grid2d.Index2D(_, right_col) = right
  case left_col <= right_col {
    True -> #(left, right)
    False -> #(right, left)
  }
}

fn box_pair(
  index: grid2d.Index2D,
  tile: DoubleTile,
) -> #(grid2d.Index2D, grid2d.Index2D) {
  let grid2d.Index2D(row, col) = index
  case tile {
    LeftBox -> normalize_pair(index, grid2d.Index2D(row, col + 1))
    RightBox -> normalize_pair(grid2d.Index2D(row, col - 1), index)
    _ -> #(index, index)
  }
}

fn pair_member(
  pairs: List(#(grid2d.Index2D, grid2d.Index2D)),
  pair: #(grid2d.Index2D, grid2d.Index2D),
) -> Bool {
  list.any(pairs, fn(existing) {
    let #(el, er) = existing
    let #(pl, pr) = pair
    el == pl && er == pr
  })
}

fn push_pair(
  grid: grid2d.Grid2D(DoubleTile),
  left: grid2d.Index2D,
  right: grid2d.Index2D,
  direction: Direction,
  visited: List(#(grid2d.Index2D, grid2d.Index2D)),
) -> Result(grid2d.Grid2D(DoubleTile), Nil) {
  let pair = normalize_pair(left, right)
  case pair_member(visited, pair) {
    True -> Ok(grid)
    False -> {
      let #(pair_left, pair_right) = pair
      let visited = [pair, ..visited]
      let next_left = apply_direction(pair_left, direction)
      let next_right = apply_direction(pair_right, direction)

      use grid_after_left <- result.try(push_neighbor(
        grid,
        next_left,
        direction,
        visited,
        pair,
      ))

      use grid_after_both <- result.try(push_neighbor(
        grid_after_left,
        next_right,
        direction,
        visited,
        pair,
      ))

      Ok(
        grid_after_both
        |> dict.delete(pair_left)
        |> dict.delete(pair_right)
        |> dict.insert(next_left, LeftBox)
        |> dict.insert(next_right, RightBox),
      )
    }
  }
}

fn push_neighbor(
  grid: grid2d.Grid2D(DoubleTile),
  position: grid2d.Index2D,
  direction: Direction,
  visited: List(#(grid2d.Index2D, grid2d.Index2D)),
  current_pair: #(grid2d.Index2D, grid2d.Index2D),
) -> Result(grid2d.Grid2D(DoubleTile), Nil) {
  let #(pair_left, pair_right) = current_pair
  case position == pair_left || position == pair_right {
    True -> Ok(grid)
    False ->
      case dict.get(grid, position) {
        Ok(DoubleWall) -> Error(Nil)
        Ok(LeftBox) -> {
          let #(left, right) = box_pair(position, LeftBox)
          push_pair(grid, left, right, direction, visited)
        }
        Ok(RightBox) -> {
          let #(left, right) = box_pair(position, RightBox)
          push_pair(grid, left, right, direction, visited)
        }
        Ok(DoubleRobot) -> Error(Nil)
        Error(_) -> Ok(grid)
      }
  }
}

fn push_boxes(
  grid: grid2d.Grid2D(DoubleTile),
  index: grid2d.Index2D,
  direction: Direction,
) -> Result(grid2d.Grid2D(DoubleTile), Nil) {
  case dict.get(grid, index) {
    Ok(LeftBox) -> {
      let #(left, right) = box_pair(index, LeftBox)
      push_pair(grid, left, right, direction, [])
    }
    Ok(RightBox) -> {
      let #(left, right) = box_pair(index, RightBox)
      push_pair(grid, left, right, direction, [])
    }
    _ -> Ok(grid)
  }
}

fn move_robot(
  grid: grid2d.Grid2D(DoubleTile),
  robot: grid2d.Index2D,
  direction: Direction,
) -> #(grid2d.Grid2D(DoubleTile), grid2d.Index2D) {
  let next = apply_direction(robot, direction)
  case dict.get(grid, next) {
    Ok(DoubleWall) -> #(grid, robot)
    Ok(LeftBox) ->
      case push_boxes(grid, next, direction) {
        Ok(grid_after_push) -> #(
          set_robot_position(grid_after_push, robot, next),
          next,
        )
        Error(_) -> #(grid, robot)
      }
    Ok(RightBox) ->
      case push_boxes(grid, next, direction) {
        Ok(grid_after_push) -> #(
          set_robot_position(grid_after_push, robot, next),
          next,
        )
        Error(_) -> #(grid, robot)
      }
    Ok(_) -> #(set_robot_position(grid, robot, next), next)
    Error(_) -> #(set_robot_position(grid, robot, next), next)
  }
}

fn gps_coordinate(index: grid2d.Index2D) -> Int {
  let grid2d.Index2D(row, col) = index
  row * 100 + col
}

pub fn solve(input: Input) -> Output {
  use #(grid, robot, directions) <- result.try(input)

  let double_grid = to_double_grid(grid)
  let double_robot = double_robot_index(robot)

  let #(final_grid, _) =
    list.fold(directions, #(double_grid, double_robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

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
  let double_robot = double_robot_index(robot)

  render_grid(double_grid, double_tile_to_char) |> io.println

  let #(final_grid, _) =
    list.fold(directions, #(double_grid, double_robot), fn(acc, direction) {
      let #(grid, robot) = acc
      move_robot(grid, robot, direction)
    })

  render_grid(final_grid, double_tile_to_char) |> io.println
}
