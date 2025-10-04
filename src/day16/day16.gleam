import common/grid2d
import gleam/set

/// Day 16 takes place on a grid where the reindeer can face four cardinal
/// directions. We keep the orientation explicit so the solver can charge the
/// correct cost when the reindeer turns.
pub type Direction {
  North
  East
  South
  West
}

/// Everything the navigation code needs: the start tile paired with its
/// initial heading, the goal tile, and the set of impassable wall locations.
pub type ValidInput {
  ValidInput(
    start: #(grid2d.Index2D, Direction),
    end: grid2d.Index2D,
    walls: set.Set(grid2d.Index2D),
  )
}

/// Parsing succeeds with a `ValidInput`; otherwise we surface a friendly error
/// string. Storing the result like this keeps the call-sites consistent with the
/// rest of the project.
pub type Input =
  Result(ValidInput, String)

/// Both parts ultimately report a single integer. We wrap it in a `Result`
/// so errors can bubble upward alongside successful answers.
pub type Output =
  Result(Int, String)

/// File-system helpers for the real puzzle input and the two sample mazes.
pub const input_path = "inputs/day16/input.txt"

pub const example1_path = "test/day16/examples/example1.txt"

pub const example2_path = "test/day16/examples/example2.txt"
