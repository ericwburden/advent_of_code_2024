/// Because both parts end up needing slightly different data structures to
/// calculate the disk checksum efficiently, we'll keep the [Input] simple
/// as just the list of integers in the input file.
pub type Input =
  Result(List(Int), String)

/// The results for this puzzle will be a calculated checksum value in the 
/// form of an integer.
pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day09/input.txt"

pub const example1_path = "test/day09/examples/example1.txt"

pub const example2_path = "test/day09/examples/example2.txt"
