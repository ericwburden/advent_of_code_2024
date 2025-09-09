import day04/day04.{
  type CharGrid, type Index2D, type Input, type Output, A, M, S,
}
import day04/part1.{
  None, NorthEast, NorthWest, SouthEast, SouthWest, nudge_index,
}
import gleam/dict
import gleam/list
import gleam/result

// For part two, we're looking for the letters 'M-A-S' in an 'X' shape! Tricksy!
// Except, there are only four different ways the letters can be arranged around
// the central 'A', so instead of generating the patterns to search for
// dynamically, I've opted to hard-code them.
const possible_patterns = [
  [
    #(None, A),
    #(NorthWest, M),
    #(SouthEast, S),
    #(NorthEast, M),
    #(SouthWest, S),
  ],
  [
    #(None, A),
    #(NorthEast, M),
    #(SouthWest, S),
    #(SouthEast, M),
    #(NorthWest, S),
  ],
  [
    #(None, A),
    #(SouthEast, M),
    #(NorthWest, S),
    #(SouthWest, M),
    #(NorthEast, S),
  ],
  [
    #(None, A),
    #(NorthWest, M),
    #(SouthEast, S),
    #(SouthWest, M),
    #(NorthEast, S),
  ],
]

/// Updated for Part 2, now this function uses the patterns from above, checks
/// all four to see if they're present centered on the [Char] at `idx`, and 
/// returns whether any of the four patterns is found.
fn is_xmas(grid: CharGrid, idx: Index2D) -> Bool {
  // Using the hard-coded patterns...
  possible_patterns
  // Replace the [Direction] in the pattern tuple with the [Index2D] to 
  // check for the [Char].
  |> list.map(fn(pattern) {
    list.map(pattern, fn(pair) { #(nudge_index(idx, pair.0), pair.1) })
  })
  // Then use the same method as before, returning true if any of the four
  // patterns matches the index we're checking
  |> list.any(fn(pattern) {
    list.fold_until(pattern, from: True, with: fn(continue, pair) {
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
  })
}

/// Part two relies on a clever pun to have us searching for 'X-MAS', or the
/// letters 'M-A-S' in an 'X' shape. Because we've modified our `is_xmas` 
/// method to accommodate this, the `solve` function doesn't actually have 
/// to change at all. Nice!
pub fn solve(input: Input) -> Output {
  use char_grid <- result.map(input)
  dict.keys(char_grid)
  |> list.count(fn(idx) { is_xmas(char_grid, idx) })
}
