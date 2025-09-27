import day09/day09.{type Input, type Output}
import day09/parse
import gleam/io
import gleam/list
import gleam/result

pub type IndexedFile {
  IndexedFile(idx: Int, len: Int, id: Int)
}

pub type IndexedFreeSpace {
  IndexedFreeSpace(idx: Int, len: Int)
}

fn checksum_value(file: IndexedFile) -> Int {
  let IndexedFile(idx, len, id) = file
  let last = idx + len - 1
  let sum = len * { idx + last }
  id * { sum / 2 }
}

fn update_free_list(
  frees: List(IndexedFreeSpace),
  free_idx: Int,
  free_len: Int,
  file_len: Int,
) -> List(IndexedFreeSpace) {
  case free_len - file_len {
    0 -> list.filter(frees, fn(x) { x.idx != free_idx })

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

pub type ChecksumIter {
  ChecksumIter(free_list: List(IndexedFreeSpace), files_rev: List(IndexedFile))
}

fn checksum_iter(disk_map: List(Int)) -> ChecksumIter {
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

  ChecksumIter(list.reverse(frees), files)
}

fn next_checksum_value(iter: ChecksumIter) -> Result(#(Int, ChecksumIter), Nil) {
  let ChecksumIter(frees, files_rev) = iter
  case files_rev {
    [] -> Error(Nil)
    [IndexedFile(file_idx, file_len, file_id), ..files_left] -> {
      let available_space =
        list.find(frees, fn(free) {
          let IndexedFreeSpace(free_idx, free_len) = free
          free_idx < file_idx && free_len >= file_len
        })

      case available_space {
        Ok(IndexedFreeSpace(free_idx, free_len)) -> {
          let next_file = IndexedFile(free_idx, file_len, file_id)
          let next_checksum = checksum_value(next_file)
          let updated_frees =
            update_free_list(frees, free_idx, free_len, file_len)
          Ok(#(next_checksum, ChecksumIter(updated_frees, files_left)))
        }
        Error(_) -> {
          let next_file = IndexedFile(file_idx, file_len, file_id)
          let next_checksum = checksum_value(next_file)
          Ok(#(next_checksum, ChecksumIter(frees, files_left)))
        }
      }
    }
  }
}

fn calculate_checksum(iter: ChecksumIter) -> Int {
  recurse_calculate_checksum(iter, 0)
}

fn recurse_calculate_checksum(iter: ChecksumIter, acc: Int) -> Int {
  case next_checksum_value(iter) {
    Ok(#(val, next_iter)) -> recurse_calculate_checksum(next_iter, acc + val)
    Error(_) -> acc
  }
}

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
  |> io.debug
}
