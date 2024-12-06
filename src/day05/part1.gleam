import day05/day05.{type Input, type Output}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string

pub type RuleLookupDict =
  dict.Dict(Int, set.Set(Int))

fn add_rule_to_lookup(
  lookup: RuleLookupDict,
  rule: day05.PageOrderingRule,
) -> RuleLookupDict {
  dict.upsert(in: lookup, update: rule.page, with: fn(x) {
    case x {
      Some(pages) -> set.insert(pages, rule.after)
      None -> set.new() |> set.insert(rule.after)
    }
  })
}

pub fn transform_rules_to_lookup_dict(
  rules: List(day05.PageOrderingRule),
) -> RuleLookupDict {
  list.fold(over: rules, from: dict.new(), with: add_rule_to_lookup)
}

pub fn page_compare(lookup: RuleLookupDict, left: Int, right: Int) -> Bool {
  case dict.get(lookup, left) {
    Error(Nil) -> False
    Ok(pages_after) -> set.contains(pages_after, right)
  }
}

pub fn is_sorted(lookup: RuleLookupDict, pages: List(Int)) -> Bool {
  list.window_by_2(pages)
  |> list.all(fn(pair) {
    let #(left, right) = pair
    page_compare(lookup, left, right)
  })
}

pub fn extract_middle_page(pages: List(Int)) -> Result(Int, String) {
  let middle_index = list.length(pages) / 2
  list.index_map(pages, fn(el, idx) { #(idx, el) })
  |> list.key_find(middle_index)
  |> result.replace_error(
    "The list "
    <> string.inspect(pages)
    <> " does not have the index "
    <> int.to_string(middle_index)
    <> "!",
  )
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let #(rules, lists) = input
  let lookup = transform_rules_to_lookup_dict(rules)

  lists
  |> list.filter(fn(pages) { is_sorted(lookup, pages) })
  |> list.map(extract_middle_page)
  |> result.all
  |> result.map(int.sum)
}
