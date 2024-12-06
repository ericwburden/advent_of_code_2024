import day05/day05.{type Input, type PageOrderingRule}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_int_with_err(str: String) -> Result(Int, String) {
  str
  |> int.parse
  |> result.replace_error("Could not parse an Int from '" <> str <> "'!")
}

fn parse_rule(str: String) -> Result(PageOrderingRule, String) {
  let split_result =
    str
    |> string.split_once("|")
    |> result.replace_error(
      "Could not split '" <> str <> "' into parts by '|'!",
    )
  use #(left_str, right_str) <- result.try(split_result)
  use page <- result.try(parse_int_with_err(left_str))
  use after <- result.map(parse_int_with_err(right_str))
  day05.PageOrderingRule(page, after)
}

fn parse_int_list(str: String) -> Result(List(Int), String) {
  str |> string.split(",") |> list.map(parse_int_with_err) |> result.all
}

pub fn read_input(input_path) -> Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map(string.trim)
    |> result.replace_error("Could not read file at '" <> input_path <> "'!")

  use contents <- result.try(read_result)
  let split_parts_result =
    contents
    |> string.split_once("\n\n")
    |> result.replace_error("Cannot split the input file on empty line!")

  use #(rules_part, lists_part) <- result.try(split_parts_result)
  let rules_result =
    rules_part |> string.split("\n") |> list.map(parse_rule) |> result.all
  use rules <- result.try(rules_result)

  let lists_result =
    lists_part |> string.split("\n") |> list.map(parse_int_list) |> result.all
  use lists <- result.map(lists_result)
  #(rules, lists)
}
