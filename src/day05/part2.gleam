import day05/day05.{type Input, type Output}
import day05/part1
import gleam/int
import gleam/list
import gleam/order
import gleam/result

fn sort_pages(lookup: part1.RuleLookupDict, pages: List(Int)) -> List(Int) {
  list.sort(pages, by: fn(left, right) {
    case part1.page_compare(lookup, left, right) {
      True -> order.Lt
      False -> order.Gt
    }
  })
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let #(rules, lists) = input
  let lookup = part1.transform_rules_to_lookup_dict(rules)

  lists
  |> list.filter(fn(pages) { !part1.is_sorted(lookup, pages) })
  |> list.map(fn(pages) { sort_pages(lookup, pages) })
  |> list.map(part1.extract_middle_page)
  |> result.all
  |> result.map(int.sum)
}
