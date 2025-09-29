import gleam/dict
import gleam/list

/// This will be the index for each character in the original grid.
pub type Index2D {
  Index2D(row: Int, col: Int)
}

pub type Offset2D {
  Offset2D(rows: Int, cols: Int)
}

pub fn get_offset(idx1: Index2D, idx2: Index2D) -> Offset2D {
  let Index2D(row1, col1) = idx1
  let Index2D(row2, col2) = idx2
  Offset2D(row2 - row1, col2 - col1)
}

pub fn apply_offset(idx: Index2D, offset: Offset2D) -> Index2D {
  let Index2D(row, col) = idx
  let Offset2D(rows, cols) = offset
  Index2D(row + rows, col + cols)
}

pub const cardinal_offsets = [
  Offset2D(1, 0),
  Offset2D(0, 1),
  Offset2D(-1, 0),
  Offset2D(0, -1),
]

pub type Grid2D(a) =
  dict.Dict(Index2D, a)

pub fn from_list(list: List(#(Index2D, a))) -> Grid2D(a) {
  dict.from_list(list)
}

pub fn get(from: Grid2D(a), idx: Index2D) -> Result(a, Nil) {
  dict.get(from, idx)
}

pub fn cardinal_neighbors_like(
  from: Grid2D(a),
  idx: Index2D,
  like: fn(a) -> Bool,
) -> List(Index2D) {
  cardinal_offsets
  |> list.map(fn(offset) { apply_offset(idx, offset) })
  |> list.filter(fn(neighbor_idx) {
    case get(from, neighbor_idx) {
      Ok(val) -> like(val)
      Error(_) -> False
    }
  })
}
