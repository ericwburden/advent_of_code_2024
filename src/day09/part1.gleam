import day09/day09.{
  type FileOrFreeSpace, type Input, type Output, FileBlock, FreeSpace,
}
import day09/parse
import gleam/deque
import gleam/io
import gleam/list
import gleam/result

fn expand_disk_map(disk_map: List(Int)) -> List(FileOrFreeSpace) {
  let #(_, expanded_list) =
    list.index_fold(disk_map, #(True, []), fn(acc, n, idx) {
      case acc {
        #(True, blocks_so_far) -> {
          let next_blocks = list.repeat(day09.FileBlock(idx / 2), n)
          let all_blocks = list.append(blocks_so_far, next_blocks)
          #(False, all_blocks)
        }
        #(False, blocks_so_far) -> {
          let next_blocks = list.repeat(day09.FreeSpace, n)
          let all_blocks = list.append(blocks_so_far, next_blocks)
          #(True, all_blocks)
        }
      }
    })

  expanded_list
}

fn compact_files(expanded_disk_map: List(FileOrFreeSpace)) -> List(Int) {
  // Stripping the empty spaces from the reversed list helps cut down on the
  // number of recursive calls needed.
  let reversed_disk_map =
    list.reverse(expanded_disk_map)
    |> list.filter(fn(block) {
      case block {
        FreeSpace -> False
        _ -> True
      }
    })

  let blocks_to_process = list.length(reversed_disk_map)

  recurse_compact_files(
    expanded_disk_map,
    reversed_disk_map,
    blocks_to_process,
    [],
  )
}

fn recurse_compact_files(
  expanded_disk_map: List(FileOrFreeSpace),
  reversed_disk_map: List(FileOrFreeSpace),
  blocks_to_process: Int,
  acc: List(Int),
) -> List(Int) {
  case expanded_disk_map, reversed_disk_map, blocks_to_process {
    _, _, 0 | [], _, _ | _, [], _ -> list.reverse(acc)

    // Expanded head is a file block: just take it
    [FileBlock(n), ..edm_tail], rdm, rem ->
      recurse_compact_files(edm_tail, rdm, rem - 1, [n, ..acc])

    // Expanded head is free space, reversed head is a file block: pull from reversed
    [FreeSpace, ..edm_tail], [FileBlock(n), ..rdm_tail], rem ->
      recurse_compact_files(edm_tail, rdm_tail, rem - 1, [n, ..acc])

    // Because the reversed list is pre-filtered to only [FileBlock]s, there
    // is no other valid pattern, but the compiler doesn't know that. So, here's
    // a catch-all in case I'm wrong.
    _, _, _ -> panic as "I have made a terrible error in logic!"
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
