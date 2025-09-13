pub type FileOrFreeSpace {
  FileBlock(Int)
  FreeSpace
}

pub type BlockAccumulator {
  FileAccumulator(blocks: List(FileOrFreeSpace))
  FreeSpaceAccumulator(blocks: List(FileOrFreeSpace))
}

pub type Input =
  Result(List(Int), String)

pub type Output =
  Result(Int, String)

pub const input_path = "test/day09/input/input.txt"

pub const example1_path = "test/day09/examples/example1.txt"

pub const example2_path = "test/day09/examples/example2.txt"
