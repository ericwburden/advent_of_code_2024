/// This will be the index for each character in the original grid.
pub type Index2D {
  Index2D(row: Int, col: Int)
}

/// Describes how to execute and validate an individual puzzle part when
/// running from the command line harness. Each part knows the label to show in
/// the console, the expected answer, and the solver function that produces the
/// actual answer. Different variants allow us to support multiple output
/// types.
pub type RunnerPart(input) {
  IntPart(
    label: String,
    expected: Int,
    solver: fn(input) -> Result(Int, String),
  )
  StringPart(
    label: String,
    expected: String,
    solver: fn(input) -> Result(String, String),
  )
}
