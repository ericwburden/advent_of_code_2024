import common/types.{type Index2D}
import gleam/dict

/// Turns out Gleam doesn't have a `character` data type, so to avoid the
/// memory overhead of a grid of full-blown [String]s, I'm opting to just
/// represent the four characters we care about as type variants.
pub type Char {
  X
  M
  A
  S
}

/// Also, it seems like Gleam's lists are not well-suited to indexing, being
/// singly linked lists. In other languages, I'd avoid the extra overhead of
/// hash map lookups, but I feel like traversing linked lists inside linked
/// lists will be similar in processing time and harder to read the code for.
pub type CharGrid =
  dict.Dict(Index2D, Char)

pub type Input =
  Result(CharGrid, String)

pub type Output =
  Result(Int, String)

pub const input_path = "test/day04/input/input.txt"

pub const example1_path = "test/day04/examples/example1.txt"

pub const example2_path = "test/day04/examples/example2.txt"
