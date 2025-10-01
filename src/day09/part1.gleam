import day09/day09.{type Input, type Output}
import day09/parse
import gleam/deque
import gleam/io
import gleam/list
import gleam/result

/// The disk contains either a [File] with an ID and a length or a [FreeSpace]
/// with just a length.
pub type DiskContents {
  File(len: Int, id: Int)
  FreeSpace(len: Int)
}

/// An individual block from a File or a FreeSpace
pub type DiskBlock {
  FileBlock(id: Int)
  FreeBlock
}

/// We'll materialize [DiskBlock]s from the beginning and end of the disk, 
/// so we'll use a [Deque] to store our [DiskContents].
pub type DiskMap =
  deque.Deque(DiskContents)

/// Convert the input into a [DiskMap] to set us up for calculating the
/// checksum on the fly.
fn make_disk_map(input: List(Int)) -> DiskMap {
  // We'll alternate between interpreting numbers from the input as a 
  // [File] and a [FreeSpace]. 
  let #(_, disk_map) =
    list.index_fold(input, #(True, []), fn(acc, n, idx) {
      case acc {
        #(True, blocks_so_far) ->
          // The index of each [File] will be half the number of items
          // processed, since every other item will be a [FreeSpace].
          #(False, [File(n, idx / 2), ..blocks_so_far])

        // Note how we're toggling the first tuple member of the accumulator
        // in order to flip back and forth between parsing each number from
        // the input as a [File] or [FreeSpace].
        #(False, blocks_so_far) -> #(True, [FreeSpace(n), ..blocks_so_far])
      }
    })

  // Since adding items to a Gleam list adds the items to the front of the
  // list, we have to reverse our output so that it will be in the same order
  // as the input. We _could_ leave it reversed (since our data structure is
  // a [Deque]), but that feels like a readability cost without sufficient
  // benefit to the algorithm.
  disk_map |> list.reverse |> deque.from_list
}

/// Pop the first [DiskBlock] from the [DiskMap]. Since the [DiskMap] actually
/// contains [DiskContents], i.e. whole file and free-space representations,
/// we're actually shrinking the first [DiskContents] until it has a `len`
/// of zero before we actually remove the first item from the [DiskMap].
fn pop_first_block(disk_map: DiskMap) -> Result(#(DiskBlock, DiskMap), Nil) {
  let deque_pop_result = deque.pop_front(disk_map)
  use #(first, rest) <- result.try(deque_pop_result)

  case first {
    // If the first [DiskContents] is zero-length, skip it and grab the
    // next item from the front of the [DiskMap].
    File(0, _) | FreeSpace(0) -> pop_first_block(rest)

    // If the first [DiskContents] is a File with some length remaining,
    // produce a [FileBlock] and shrink the [File].
    File(len, id) -> {
      let dm = deque.push_front(rest, File(len - 1, id))
      Ok(#(FileBlock(id), dm))
    }

    // If the first [DiskContents] is a FreeSpace with some length remaining,
    // produce a [FreeBlock] and shrink the [FreeSpace].
    FreeSpace(len) -> {
      let dm = deque.push_front(rest, FreeSpace(len - 1))
      Ok(#(FreeBlock, dm))
    }
  }
}

/// Pop the last [FileBlock] that can be derived from the [DiskMap]. Again, the
/// [DiskMap] contains full [DiskContents] (of both types), so we may have to 
/// dig a bit for the last [File] and shrink it to produce a [FileBlock].
fn pop_last_file_block_id(disk_map: DiskMap) -> Result(#(Int, DiskMap), Nil) {
  // Need to check to be sure there's actually something in the [DiskMap].
  let deque_pop_result = deque.pop_back(disk_map)
  use #(first, rest) <- result.try(deque_pop_result)

  case first {
    // If the last item in the [DiskMap] is a zero-length [File] or a 
    // [FreeSpace] of any size, skip it and move on
    File(0, _) | FreeSpace(_) -> pop_last_file_block_id(rest)

    // If the last item is a [File] with some length remaining, shrink it by
    // one and produce a [FileBlock].
    File(len, id) -> {
      let dm = deque.push_back(rest, File(len - 1, id))
      Ok(#(id, dm))
    }
  }
}

/// This is a convenience function to grab the next file ID that can be
/// produced from the [DiskMap]. If the first item in the [DiskMap] is a 
/// [File], grab a block from it. If the first item in the [DiskMap] is a
/// [FreeSpace] with space remaining, grab the first [FileBlock] from the back
/// of the [DiskMap]. Wherever the [FileBlock] comes from (front or back), 
/// return the file's ID and the updated [DiskMap].
fn pop_next_file_id(disk_map: DiskMap) -> Result(#(Int, DiskMap), Nil) {
  // Verify that the [DiskMap] is not empty
  let pop_first_block_result = pop_first_block(disk_map)
  use #(first, rest) <- result.try(pop_first_block_result)

  // If there's a [File] at the beginning, grab that ID, otherwise
  // grab the ID of the last [File] in the [DiskMap].
  case first {
    FileBlock(id) -> Ok(#(id, rest))
    FreeBlock -> pop_last_file_block_id(rest)
  }
}

/// Calculate the full checksum of the entire [DiskMap].
fn calculate_checksum(disk_map: DiskMap) -> Int {
  recurse_calculate_checksum(disk_map, 0, 0)
}

/// The recursive implementation of `calculate_checksum`.
fn recurse_calculate_checksum(disk_map: DiskMap, idx: Int, acc: Int) -> Int {
  // Grab the file ID of the next [File] that will contribute to the checksum
  // and add it's checksum value (the file ID times the current index) to the
  // accumulator.
  case pop_next_file_id(disk_map) {
    // Base case, when the [DiskMap] is empty
    Error(_) -> acc

    Ok(#(next_value, rest)) -> {
      let acc = acc + { idx * next_value }
      recurse_calculate_checksum(rest, idx + 1, acc)
    }
  }
}

/// To solve this puzzle, we simulate what would happen if we re-arranged the
/// individual blocks of [File]s and [FreeSpace]s without actually implementing
/// moving them around (since that would be slow and unnecessary). Instead, we
/// pull from the front and back of the [DiskMap], as appropriate, adding the 
/// relevant checksum value to the total until all [FileBlock]s have been
/// examined.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let checksum =
    input
    |> make_disk_map
    |> calculate_checksum

  Ok(checksum)
}

pub fn main() -> Output {
  day09.input_path
  |> parse.read_input
  |> solve
  |> echo
}
