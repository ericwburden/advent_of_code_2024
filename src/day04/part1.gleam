import day04/day04.{
  type CharGrid, type Index2D, type Input, type Output, A, Index2D, M, S, X,
}
import gleam/dict
import gleam/int
import gleam/list
import gleam/result

/// Just your everyday type with variants representing the available directions
/// on a grid. 
pub type Direction {
  None
  North
  NorthEast
  East
  SouthEast
  South
  SouthWest
  West
  NorthWest
}

// And here's a handy list of all the [Direction]s, for convenience.
const directions = [
  North,
  NorthEast,
  East,
  SouthEast,
  South,
  SouthWest,
  West,
  NorthWest,
]

// Along with a list of the letters, again for convenience.
const letters = [X, M, A, S]

/// Starting at `idx`, returns the next [Index2D] found by moving
/// in the given `direction`.
pub fn nudge_index(idx: Index2D, direction: Direction) -> Index2D {
  case direction {
    None -> idx
    North -> Index2D(idx.row - 1, idx.col)
    NorthEast -> Index2D(idx.row - 1, idx.col + 1)
    East -> Index2D(idx.row, idx.col + 1)
    SouthEast -> Index2D(idx.row + 1, idx.col + 1)
    South -> Index2D(idx.row + 1, idx.col)
    SouthWest -> Index2D(idx.row + 1, idx.col - 1)
    West -> Index2D(idx.row, idx.col - 1)
    NorthWest -> Index2D(idx.row - 1, idx.col - 1)
  }
}

/// In order to find an 'XMAS' string, we need to check for four characters along
/// a line in a given direction. This function returns a list containing the
/// original index and the next three indices, in order, in the given direction.
fn indices_to_check(idx: Index2D, direction: Direction) -> List(Index2D) {
  list.repeat(direction, 3)
  |> list.prepend(None)
  |> list.scan(idx, nudge_index)
}

/// Starting at `idx` and checking a line in a given `direction`, determine if
/// the characters on the `grid` spell out the word 'XMAS'.
fn is_xmas(grid: CharGrid, idx: Index2D, direction: Direction) -> Bool {
  indices_to_check(idx, direction)
  |> list.zip(letters)
  |> list.fold_until(from: True, with: fn(continue, pair) {
    // Here we're taking advantage of early returns from `fold_until`. If we try
    // to check an index that doesn't exist or the letter we're looking for
    // isn't there, we can stop checking.
    let #(idx, letter) = pair
    case dict.get(grid, idx) {
      Error(Nil) -> list.Stop(False)
      Ok(found) ->
        case letter == found {
          True -> list.Continue(continue)
          False -> list.Stop(False)
        }
    }
  })
}

/// Counts the number of times 'XMAS' can be spelled starting at a given [Index2D]
/// and checking in all eight possible directions. Each direction counts as one
/// distinct 'XMAS' if found.
fn count_xmas_at(grid: CharGrid, idx: Index2D) -> Int {
  directions |> list.count(fn(d) { is_xmas(grid, idx, d) })
}

/// For part one, we take each space in our grid and then check in all eight possible
/// directions from that space to find every instance of the word 'XMAS' in our
/// grid of characters.
pub fn solve(input: Input) -> Output {
  use char_grid <- result.map(input)
  dict.keys(char_grid)
  |> list.map(fn(idx) { count_xmas_at(char_grid, idx) })
  |> int.sum
}
