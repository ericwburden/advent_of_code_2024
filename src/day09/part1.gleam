import day09/day09.{
  type FileOrFreeSpace, type Input, type Output, FileBlock, FreeSpace,
}
import day09/parse
import gleam/io
import gleam/list
import gleam/result

fn expand_disk_map(disk_map: List(Int)) -> List(FileOrFreeSpace) {
  let expansion_accumulator =
    list.index_fold(disk_map, day09.FileAccumulator([]), fn(acc, n, idx) {
      case acc {
        day09.FileAccumulator(expanded_list) -> {
          let next_blocks = list.repeat(day09.FileBlock(idx / 2), n)
          let all_blocks = list.append(expanded_list, next_blocks)
          day09.FreeSpaceAccumulator(all_blocks)
        }
        day09.FreeSpaceAccumulator(expanded_list) -> {
          let next_blocks = list.repeat(day09.FreeSpace, n)
          let all_blocks = list.append(expanded_list, next_blocks)
          day09.FileAccumulator(all_blocks)
        }
      }
    })

  case expansion_accumulator {
    day09.FileAccumulator(expanded_list) -> expanded_list
    day09.FreeSpaceAccumulator(expanded_list) -> expanded_list
  }
}

fn compact_files(expanded_disk_map: List(FileOrFreeSpace)) -> List(Int) {
  let reversed_disk_map = list.reverse(expanded_disk_map)
  let blocks_to_process =
    expanded_disk_map
    |> list.count(fn(block) {
      case block {
        FileBlock(_) -> True
        FreeSpace -> False
      }
    })
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
    [], _, _ | _, [], _ | _, _, 0 -> list.reverse(acc)

    // Expanded head is a file block: just take it
    [FileBlock(n), ..edm_tail], rdm, rem ->
      recurse_compact_files(edm_tail, rdm, rem - 1, [n, ..acc])

    // Expanded head is free space, reversed head is a file block: pull from reversed
    [FreeSpace, ..edm_tail], [FileBlock(n), ..rdm_tail], rem ->
      recurse_compact_files(edm_tail, rdm_tail, rem - 1, [n, ..acc])

    // Expanded head is free space, reversed head is also free space: skip both
    [FreeSpace, ..edm_tail], [FreeSpace, ..rdm_tail], rem ->
      recurse_compact_files(expanded_disk_map, rdm_tail, rem, acc)
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
