import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

fn can_compose_arrangement(towels: List(String), arrangement: String) -> Bool {
  let usable_towels =
    towels
    |> list.map(string.trim)
    |> list.filter(fn(towel) { string.length(towel) > 0 })

  let normalized_arrangement = string.trim(arrangement)

  let #(result, _) =
    can_compose_arrangement_go(
      usable_towels,
      normalized_arrangement,
      dict.new(),
    )
  result
}

fn can_compose_arrangement_go(
  towels: List(String),
  arrangement: String,
  memo: Dict(String, Bool),
) -> #(Bool, Dict(String, Bool)) {
  case dict.get(memo, arrangement) {
    Ok(result) -> #(result, memo)
    Error(Nil) ->
      case string.length(arrangement) == 0 {
        True -> {
          let updated = dict.insert(memo, arrangement, True)
          #(True, updated)
        }
        False -> {
          let #(success, updated_memo) =
            list.fold(towels, #(False, memo), fn(acc, towel) {
              let #(already_successful, seen_memo) = acc
              case already_successful {
                True -> #(True, seen_memo)
                False -> {
                  case string.starts_with(arrangement, towel) {
                    False -> #(False, seen_memo)
                    True -> {
                      let remainder =
                        string.drop_start(arrangement, string.length(towel))
                      let #(can_build_rest, next_memo) =
                        can_compose_arrangement_go(towels, remainder, seen_memo)
                      case can_build_rest {
                        True -> {
                          let memo_with_hit =
                            dict.insert(next_memo, arrangement, True)
                          #(True, memo_with_hit)
                        }
                        False -> #(False, next_memo)
                      }
                    }
                  }
                }
              }
            })

          let final_memo = dict.insert(updated_memo, arrangement, success)
          #(success, final_memo)
        }
      }
  }
}

pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)

  arrangements
  |> list.filter(fn(arrangement) {
    can_compose_arrangement(towels, arrangement)
  })
  |> list.length
  |> Ok
}

pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
