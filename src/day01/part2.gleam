import day01/day01.{type Input, type Output}
import gleam/dict
import gleam/list
import gleam/result

// Probably could have used a helper function here, but I think it's fine.
// For part two, we need to count how many times each value in the left list appears
// in the right list, multiply the unique values by their number of occurrences, then
// add all those products together.
pub fn solve(input: Input) -> Output {
  // Assuming we parsed our input...
  use input_ok <- result.map(input)

  // Still helpful to have the two lists separately
  let #(left_list, right_list) = list.unzip(input_ok)

  // For each value in the left list, first remove the duplicates to avoid creating
  // extra work by counting for the same value multiple times. Then, tally how many
  // times that value appears in the right-hand list. This gives us a mapping of 
  // values in the left list to counts in the right list.
  let occurrence_counts =
    list.unique(left_list)
    |> list.fold(from: dict.new(), with: fn(count_dict, value) {
      dict.insert(
        count_dict,
        value,
        list.count(right_list, where: fn(x) { x == value }),
      )
    })

  // Starting with the full left list, tally the left list value times the number
  // of occurrences and return the total.
  list.fold(over: left_list, from: 0, with: fn(total, value) {
    // If the left-hand list values isn't in the mapping, then its count is zero
    let count = dict.get(occurrence_counts, value) |> result.unwrap(0)
    total + { value * count }
  })
}
