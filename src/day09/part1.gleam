import day09/day09.{type Input, type Output}
import day09/parse
import gleam/deque
import gleam/io
import gleam/list
import gleam/result

pub type DiskContents {
  File(id: Int, len: Int)
  FreeSpace(len: Int)
}

pub type DiskBlock {
  FileBlock(id: Int)
  FreeBlock
}

pub type DiskMap =
  deque.Deque(DiskContents)

fn make_disk_map(input: List(Int)) -> DiskMap {
  let #(_, disk_map) =
    list.index_fold(input, #(True, []), fn(acc, n, idx) {
      case acc {
        #(True, blocks_so_far) -> {
          let file = File(idx / 2, n)
          let all_blocks = [file, ..blocks_so_far]
          #(False, all_blocks)
        }
        #(False, blocks_so_far) -> {
          let free = FreeSpace(n)
          let all_blocks = [free, ..blocks_so_far]
          #(True, all_blocks)
        }
      }
    })

  disk_map |> list.reverse |> deque.from_list
}

fn pop_first_block(disk_map: DiskMap) -> Result(#(DiskBlock, DiskMap), Nil) {
  let deque_pop_result = deque.pop_front(disk_map)
  use #(first, rest) <- result.try(deque_pop_result)

  case first {
    File(_, 0) | FreeSpace(0) -> pop_first_block(rest)
    File(id, len) -> {
      let dm = deque.push_front(rest, File(id, len - 1))
      Ok(#(FileBlock(id), dm))
    }
    FreeSpace(len) -> {
      let dm = deque.push_front(rest, FreeSpace(len - 1))
      Ok(#(FreeBlock, dm))
    }
  }
}

fn pop_last_file_block_id(disk_map: DiskMap) -> Result(#(Int, DiskMap), Nil) {
  let deque_pop_result = deque.pop_back(disk_map)
  use #(first, rest) <- result.try(deque_pop_result)

  case first {
    File(_, 0) | FreeSpace(_) -> pop_last_file_block_id(rest)
    File(id, len) -> {
      let dm = deque.push_back(rest, File(id, len - 1))
      Ok(#(id, dm))
    }
  }
}

fn pop_next_checksum_value(disk_map: DiskMap) -> Result(#(Int, DiskMap), Nil) {
  let pop_first_block_result = pop_first_block(disk_map)
  use #(first, rest) <- result.try(pop_first_block_result)
  case first {
    FileBlock(id) -> Ok(#(id, rest))
    FreeBlock -> pop_last_file_block_id(rest)
  }
}

fn calculate_checksum(disk_map: DiskMap) -> Int {
  recurse_calculate_checksum(disk_map, 0, 0)
}

fn recurse_calculate_checksum(disk_map: DiskMap, idx: Int, acc: Int) -> Int {
  case pop_next_checksum_value(disk_map) {
    Error(_) -> acc
    Ok(#(next_value, rest)) -> {
      let acc = acc + { idx * next_value }
      recurse_calculate_checksum(rest, idx + 1, acc)
    }
  }
}

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
  |> io.debug
}
