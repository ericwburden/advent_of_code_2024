import common/grid2d
import day12/day12.{type Input, type Output}
import day12/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set

pub type Perimeters =
  grid2d.Grid2D(Int)

fn find_perimeters(plot_map: grid2d.Grid2D(UtfCodepoint)) -> Perimeters {
  plot_map
  |> dict.fold(dict.new(), fn(acc, idx, label) {
    let match_fn = fn(v) { v == label }
    let matching_neighbors =
      grid2d.cardinal_neighbors_like(plot_map, idx, match_fn)
    let perimeter = 4 - list.length(matching_neighbors)
    dict.insert(acc, idx, perimeter)
  })
}

fn build_region_containing(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  start_at: grid2d.Index2D,
) -> set.Set(grid2d.Index2D) {
  build_region_containing_go(plot_map, [start_at], set.new())
}

fn build_region_containing_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  stack: List(grid2d.Index2D),
  plots_found: set.Set(grid2d.Index2D),
) -> set.Set(grid2d.Index2D) {
  case stack {
    [] -> plots_found
    [next_idx, ..rest] ->
      case grid2d.get(plot_map, next_idx) {
        Error(_) -> panic as "Unreachable branch!"
        Ok(next_label) -> {
          let next_plots_found = set.insert(plots_found, next_idx)
          let match_fn = fn(v) { v == next_label }
          let neighboring_unchecked_plots =
            plot_map
            |> grid2d.cardinal_neighbors_like(next_idx, match_fn)
            |> list.filter(fn(i) { !set.contains(next_plots_found, i) })
          let next_stack = list.append(neighboring_unchecked_plots, rest)
          build_region_containing_go(plot_map, next_stack, next_plots_found)
        }
      }
  }
}

fn find_regions(
  plot_map: grid2d.Grid2D(UtfCodepoint),
) -> List(set.Set(grid2d.Index2D)) {
  let plots_to_visit =
    plot_map
    |> dict.keys
  let remaining = set.from_list(plots_to_visit)

  find_regions_go(plot_map, plots_to_visit, remaining, [])
  |> list.reverse
}

fn find_regions_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  plots_to_visit: List(grid2d.Index2D),
  remaining: set.Set(grid2d.Index2D),
  regions: List(set.Set(grid2d.Index2D)),
) -> List(set.Set(grid2d.Index2D)) {
  case plots_to_visit {
    [] -> regions
    [next_idx, ..rest] ->
      case set.contains(remaining, next_idx) {
        False -> find_regions_go(plot_map, rest, remaining, regions)
        True -> {
          let region = build_region_containing(plot_map, next_idx)
          let next_remaining = set.difference(remaining, region)
          find_regions_go(plot_map, rest, next_remaining, [region, ..regions])
        }
      }
  }
}

fn calculate_region_price(
  region: set.Set(grid2d.Index2D),
  perimeters: Perimeters,
) -> Int {
  let area = set.size(region)

  let perimeter =
    region
    |> set.to_list
    |> list.fold(0, fn(acc, idx) {
      case grid2d.get(perimeters, idx) {
        Ok(value) -> acc + value
        Error(_) -> panic as "Missing perimeter for index!"
      }
    })

  area * perimeter
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let perimeters = find_perimeters(input)
  let price_fn = fn(region) { calculate_region_price(region, perimeters) }

  let result =
    input
    |> find_regions
    |> list.map(price_fn)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  let read_input_result = parse.read_input(day12.input_path)
  use input <- result.try(read_input_result)

  let perimeters = find_perimeters(input)

  input
  |> find_regions
  |> list.map(fn(r) { calculate_region_price(r, perimeters) })
  |> int.sum
  |> io.debug

  Ok(0)
}
