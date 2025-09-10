/// Converts a boolean expression into a result. Useful for short-circuiting
/// a function that returns a [Result(a, Nil)] like so:
/// 
/// fn example(a: Int, b: Int, c: Int) -> Result(Int, Nil) {
///     use _ <- result.try(require(a > b))
///     use _ <- result.try(require(b > c))
///     Ok(c)
/// }
/// 
/// This function will return an Error(Nil) if either of the number comparisons
/// fail. 
pub fn require(cond: Bool) -> Result(Nil, Nil) {
  case cond {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}
