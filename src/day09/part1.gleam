import common/read_only_deque.{type ReadOnlyDeque}
import day09/day09.{type Input, type Output}
import day09/parse
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result

pub type FileOrFreeSpace {
  FileBlock(Int)
  FreeSpace
}

fn expand_disk_map(disk_map: List(Int)) -> ReadOnlyDeque(FileOrFreeSpace) {
  let #(_, expanded_list) =
    list.index_fold(disk_map, #(True, []), fn(acc, n, idx) {
      case acc {
        #(True, blocks_so_far) -> {
          let next_blocks = list.repeat(FileBlock(idx / 2), n)
          let all_blocks = list.append(blocks_so_far, next_blocks)
          #(False, all_blocks)
        }
        #(False, blocks_so_far) -> {
          let next_blocks = list.repeat(FreeSpace, n)
          let all_blocks = list.append(blocks_so_far, next_blocks)
          #(True, all_blocks)
        }
      }
    })

  read_only_deque.from_list(expanded_list)
}

fn compact_files(expanded_disk_map: ReadOnlyDeque(FileOrFreeSpace)) -> List(Int) {
  case read_only_deque.pop_front(expanded_disk_map) {
    None -> []
    Some(#(block, edm)) -> recurse_compact_files(block, edm, [])
  }
}

fn recurse_compact_files(
  next_block: FileOrFreeSpace,
  expanded_disk_map: ReadOnlyDeque(FileOrFreeSpace),
  acc: List(Int),
) -> List(Int) {
  case next_block {
    FileBlock(n) ->
      case read_only_deque.pop_front(expanded_disk_map) {
        None -> list.reverse([n, ..acc])
        Some(#(block, rest)) -> recurse_compact_files(block, rest, [n, ..acc])
      }
    FreeSpace ->
      case read_only_deque.pop_back(expanded_disk_map) {
        None -> list.reverse(acc)
        Some(#(block, rest)) -> recurse_compact_files(block, rest, acc)
      }
  }
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let checksum =
    input
    |> expand_disk_map
    |> compact_files
    |> list.index_fold(0, fn(acc, n, idx) { acc + { n * idx } })

  Ok(checksum)
}

/// Apparently running this takes too long for the unit test framework. Lame!
pub fn main() -> Output {
  day09.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
