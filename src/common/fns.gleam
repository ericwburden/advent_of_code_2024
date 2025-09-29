import gleam/int

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

/// Calculate the number of digits in a base-10 integer using integer division.
/// 
/// This function works entirely with math—no string conversions are involved.
/// - Zero is defined as having one digit (`0 -> 1`).
/// - Negative numbers are treated the same as their absolute value
///   (`-123 -> 3`).
///
/// Internally, the function repeatedly divides the number by 10 until
/// it reaches zero, counting how many steps were required.
///
/// # Examples
///
/// ```gleam
/// n_digits(0)     // -> 1
/// n_digits(7)     // -> 1
/// n_digits(42)    // -> 2
/// n_digits(12345) // -> 5
/// n_digits(-999)  // -> 3
/// ```
pub fn n_digits(n: Int) -> Int {
  // Zero has one digit. For everything else, we need to calculate.
  case int.absolute_value(n) {
    0 -> 1
    val -> n_digits_go(val, 0)
  }
}

/// Helper function for [`n_digits`](n_digits).
///
/// Recursively divides the input `n` by 10, incrementing `acc` each step,
/// until `n` becomes 0. At that point, `acc` is equal to the number of digits.
///
/// This function is not intended to be called directly outside of `n_digits`.
///
/// # Example (internal usage)
/// ```gleam
/// recurse_n_digits(123, 0) // -> 3
/// recurse_n_digits(42, 0)  // -> 2
/// recurse_n_digits(0, 0)   // -> 0  (base case)
/// ```
fn n_digits_go(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> n_digits_go(n / 10, acc + 1)
  }
}

/// Raise an integer `base` to the power of `exp` using
/// exponentiation by squaring (efficient, O(log exp)).
/// Only supports non-negative exponents.
pub fn int_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ if exp % 2 == 0 -> {
      let half = int_pow(base, exp / 2)
      half * half
    }
    _ -> base * int_pow(base, exp - 1)
  }
}
