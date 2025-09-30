import common/grid2d
import gleam/dict
import gleam/list
import gleam/set

pub type Input =
  Result(grid2d.Grid2D(UtfCodepoint), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day12/input.txt"

pub const example1_path = "test/day12/examples/example1.txt"

pub const example2_path = "test/day12/examples/example2.txt"

pub type Region =
  set.Set(grid2d.Index2D)

pub type LabelledRegion =
  #(UtfCodepoint, Region)

pub fn build_region(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  start_at: grid2d.Index2D,
) -> Region {
  build_region_go(plot_map, [start_at], set.new())
}

fn build_region_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  stack: List(grid2d.Index2D),
  plots_found: Region,
) -> Region {
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
          build_region_go(plot_map, next_stack, next_plots_found)
        }
      }
  }
}

pub fn find_regions(plot_map: grid2d.Grid2D(UtfCodepoint)) -> List(Region) {
  let plots_to_visit = dict.keys(plot_map)
  let remaining = set.from_list(plots_to_visit)

  find_regions_go(plot_map, plots_to_visit, remaining, [])
  |> list.reverse
}

fn find_regions_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  plots_to_visit: List(grid2d.Index2D),
  remaining: Region,
  regions: List(Region),
) -> List(Region) {
  case plots_to_visit {
    [] -> regions
    [next_idx, ..rest] ->
      case set.contains(remaining, next_idx) {
        False -> find_regions_go(plot_map, rest, remaining, regions)
        True -> {
          let region = build_region(plot_map, next_idx)
          let next_remaining = set.difference(remaining, region)
          find_regions_go(plot_map, rest, next_remaining, [region, ..regions])
        }
      }
  }
}

pub fn find_labelled_regions(
  plot_map: grid2d.Grid2D(UtfCodepoint),
) -> List(LabelledRegion) {
  find_regions(plot_map)
  |> list.map(fn(region) {
    case set.to_list(region) {
      [] -> panic as "Empty region discovered!"
      [idx, ..] ->
        case grid2d.get(plot_map, idx) {
          Error(_) -> panic as "Missing plot label for region!"
          Ok(label) -> #(label, region)
        }
    }
  })
}
