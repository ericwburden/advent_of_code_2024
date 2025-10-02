import day09/day09.{type Input, type Output}
import day09/parse
import gleam/list
import gleam/result

/// In Part 2, it's really helpful (for speed) if each file and free space
/// knows its own original index on the disk  (even if that's not the 
/// index ultimately used to calculate its checksum).
pub type IndexedFile {
  IndexedFile(idx: Int, len: Int, id: Int)
}

/// And, since we'll be storing files and free space separately, they can be
/// different types instead of variants on the same type. It'll save a bunch
/// of unnecessary pattern matching later on.
pub type IndexedFreeSpace {
  IndexedFreeSpace(idx: Int, len: Int)
}

/// Since an [IndexedFile] contains everything needed to calculate its own
/// checksum, we can delegate that to a handy helper function.
fn checksum_value(file: IndexedFile) -> Int {
  let IndexedFile(idx, len, id) = file
  let last = idx + len - 1
  let sum = len * { idx + last }
  id * { sum / 2 }
}

/// Given a (sorted) list of [IndexedFreeSpace] on the disk, `to_update` as the
/// [IndexedFreeSpace] to modify in the list, and `file_len` as the length of the
/// file being placed into the `to_update` free space, update the list of `frees`
/// to either shrink or remove the `to_update` free space, depending on the size
/// of the file being placed there.
fn update_free_list(
  frees: List(IndexedFreeSpace),
  to_update: IndexedFreeSpace,
  file_len: Int,
) -> List(IndexedFreeSpace) {
  let IndexedFreeSpace(free_idx, free_len) = to_update
  case free_len - file_len {
    // If there will be no space left over after placing the file, then
    // we can just drop the free space from the list of `frees`.
    0 -> list.filter(frees, fn(x) { x.idx != free_idx })

    // If the file is smaller than the free space, though, then we shift the
    // free space over and shrink it to make room.
    remaining ->
      list.map(frees, fn(x) {
        case x {
          IndexedFreeSpace(idx, _) if idx == free_idx ->
            IndexedFreeSpace(free_idx + file_len, remaining)
          _ -> x
        }
      })
  }
}

/// An iterator! In this case, [ChecksumIter] contains all the state we need
/// to iterate over the list of files contained on the disk (backwards) and
/// calculate the checksum of each file (at the location it will be moved
/// to, if it will be moved).
pub type ChecksumIter {
  ChecksumIter(free_list: List(IndexedFreeSpace), files_rev: List(IndexedFile))
}

/// Given the list of numbers from our input, construct and produce a 
/// [ChecksumIter].
fn checksum_iter(disk_map: List(Int)) -> ChecksumIter {
  // Note the complicated accumulator here. We're collecting files and free
  // spaces into their own lists. Other than that, though, the process is
  // very similar to the process in Part 1.
  let #(_, _, #(files, frees)) =
    list.index_fold(disk_map, #(True, 0, #([], [])), fn(acc, n, idx) {
      case acc {
        #(True, pos, #(files_so_far, frees_so_far)) -> {
          let next_files = [IndexedFile(pos, n, idx / 2), ..files_so_far]
          #(False, pos + n, #(next_files, frees_so_far))
        }

        #(False, pos, #(files_so_far, frees_so_far)) -> {
          let next_frees = [IndexedFreeSpace(pos, n), ..frees_so_far]
          #(True, pos + n, #(files_so_far, next_frees))
        }
      }
    })

  // Again, the lists are built in reverse order. We want the files to be
  // listed in reverse, since we'll check them in reverse order, but we need
  // to flip the list of free spaces, since we'll search for space for files
  // in increasing order of index from the original disk.
  ChecksumIter(list.reverse(frees), files)
}

/// Given the current state of a [ChecksumIter], return the next checksum value
/// in sequence (although we'll iterate in reverse order over the files on 
/// disk).
fn next_checksum_value(iter: ChecksumIter) -> Result(#(Int, ChecksumIter), Nil) {
  let ChecksumIter(frees, files_rev) = iter
  case files_rev {
    // If the list of files on disk is empty (because we've processed them 
    // all), return an Error.
    [] -> Error(Nil)

    // Otherwise, let's work with the first [IndexedFile] in the list (the
    // last one we haven't processed yet on the disk).
    [IndexedFile(file_idx, file_len, file_id), ..files_left] -> {
      // Check the list of free spaces to see if there are any spaces left
      // large enough to accommodate our file.
      let available_space =
        list.find(frees, fn(free) {
          let IndexedFreeSpace(free_idx, free_len) = free
          free_idx < file_idx && free_len >= file_len
        })

      case available_space {
        // If so, shrink (or remove) the free space accordingly and produce the
        // checksum value of the current file, along with the udpated iterator.
        Ok(free) -> {
          let next_file = IndexedFile(free.idx, file_len, file_id)
          let next_checksum = checksum_value(next_file)
          let updated_frees = update_free_list(frees, free, file_len)
          Ok(#(next_checksum, ChecksumIter(updated_frees, files_left)))
        }

        // If there's no space, then we leave the free spaces alone and just
        // calculate the checksum value of the file in its current location.
        Error(_) -> {
          let next_file = IndexedFile(file_idx, file_len, file_id)
          let next_checksum = checksum_value(next_file)
          Ok(#(next_checksum, ChecksumIter(frees, files_left)))
        }
      }
    }
  }
}

/// The workhorse! Consumes a [ChecksumIter] and returns the accumulated
/// checksum values of the entire disk.
fn calculate_checksum(iter: ChecksumIter) -> Int {
  recurse_calculate_checksum(iter, 0)
}

/// Recursive implementation of `calculate_checksum`. Adds values from the
/// [ChecksumIter] to `acc` until we run out of files to process.
fn recurse_calculate_checksum(iter: ChecksumIter, acc: Int) -> Int {
  case next_checksum_value(iter) {
    Ok(#(val, next_iter)) -> recurse_calculate_checksum(next_iter, acc + val)
    Error(_) -> acc
  }
}

/// To solve part 2, we take a similar, if actually a bit simplified, approach
/// as in part 1. Here we iterate backwards over the files on disk, attempting
/// to 'move' each one as far left as possible before calculating its checksum.
/// Since we start moving files from the end, we don't have to concern
/// ourselves with the free space left after moving a file.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let checksum =
    input
    |> checksum_iter
    |> calculate_checksum

  Ok(checksum)
}

pub fn main() -> Output {
  day09.input_path
  |> parse.read_input
  |> solve
  |> echo
}
