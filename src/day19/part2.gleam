import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

fn count_arrangement_ways(
  towels: List(String),
  arrangement: String,
  memo: Dict(String, Int),
) -> #(Int, Dict(String, Int)) {
  case dict.get(memo, arrangement) {
    Ok(existing) -> #(existing, memo)
    Error(Nil) ->
      case string.length(arrangement) == 0 {
        True -> {
          let updated = dict.insert(memo, arrangement, 1)
          #(1, updated)
        }
        False -> {
          let #(total, final_memo) =
            list.fold(towels, #(0, memo), fn(acc, towel) {
              let #(running_total, seen_memo) = acc
              case string.starts_with(arrangement, towel) {
                False -> #(running_total, seen_memo)
                True -> {
                  let remainder =
                    string.drop_start(arrangement, string.length(towel))
                  let #(count, next_memo) =
                    count_arrangement_ways(towels, remainder, seen_memo)
                  #(running_total + count, next_memo)
                }
              }
            })

          let memo_with_result = dict.insert(final_memo, arrangement, total)
          #(total, memo_with_result)
        }
      }
  }
}

pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)
  let usable_towels =
    towels
    |> list.map(string.trim)
    |> list.filter(fn(towel) { string.length(towel) > 0 })

  arrangements
  |> list.map(string.trim)
  |> list.filter(fn(arrangement) { string.length(arrangement) > 0 })
  |> list.map(fn(arrangement) {
    let #(count, _) =
      count_arrangement_ways(usable_towels, arrangement, dict.new())
    count
  })
  |> list.fold(0, fn(acc, count) { acc + count })
  |> Ok
}

pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
