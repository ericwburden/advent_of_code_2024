import common/grid2d
import gleam/dict
import gleam/list
import gleam/set

/// The input for today's puzzle is a 2D grid mapping plot locations to the
/// label associated with that plot. We're using [UtfCodepoint] for the labels,
/// since that's the most Gleam-like equivalient to a single character value,
/// and I don't want to use a whole string for simple comparisons.
pub type Input =
  Result(grid2d.Grid2D(UtfCodepoint), String)

/// The output for today is the total price of fencing for all the regions
/// in the map.
pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day12/input.txt"

pub const example1_path = "test/day12/examples/example1.txt"

pub const example2_path = "test/day12/examples/example2.txt"

/// A collection of contiguous plots that all share the same label.
pub type Region =
  set.Set(grid2d.Index2D)

/// Pair a region with the plot label it represents for quick lookups later.
pub type LabelledRegion =
  #(UtfCodepoint, Region)

/// Starting from a plot, walk to every matching neighbor and gather the
/// resulting region into a set of indices.
pub fn build_region(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  start_at: grid2d.Index2D,
) -> Region {
  build_region_go(plot_map, [start_at], set.new())
}

/// Recursive implementation for `build_region`.
fn build_region_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  stack: List(grid2d.Index2D),
  plots_found: Region,
) -> Region {
  case stack {
    // Base case, if we've checked all the plots in the stack, we're done.
    // Return all the plots visited in the same region as the plot we
    // started with.
    [] -> plots_found

    // Given an index still in the stack of plot indices to check...
    [next_idx, ..rest] ->
      // Grab its label from the `plot_map`
      case grid2d.get(plot_map, next_idx) {
        // It should always have one, so we'll leave this panic in to alert us
        // in case we've made a bad assumption.
        Error(_) -> panic as "Unreachable branch!"

        // This branch should always execute, giving us the label associated
        // with `next_idx`.
        Ok(next_label) -> {
          // Add the plot we're checking to the set of found plots.
          let next_plots_found = set.insert(plots_found, next_idx)

          // Only continue through plots that match the starting label so we
          // stay inside the current region. We also drop any plots that we've
          // checked already.
          let match_fn = fn(v) { v == next_label }
          let neighboring_unchecked_plots =
            plot_map
            |> grid2d.cardinal_neighbors_like(next_idx, match_fn)
            |> list.filter(fn(i) { !set.contains(next_plots_found, i) })

          // Add the unchecked plots to the stack and keep recursing.
          let next_stack = list.append(neighboring_unchecked_plots, rest)
          build_region_go(plot_map, next_stack, next_plots_found)
        }
      }
  }
}

/// Discover every region present in the plot map without revisiting indices.
/// The algorithm here is to pull an index from the map, build a set of all the
/// plots that share a region with it, drop the found plots from the set of all
/// possible plots, then check the next index in the map. We'll return a list
/// of regions, i.e., plot indices grouped according to their shared label.
pub fn find_regions(plot_map: grid2d.Grid2D(UtfCodepoint)) -> List(Region) {
  let plots_to_visit = dict.keys(plot_map)
  let remaining = set.from_list(plots_to_visit)

  find_regions_go(plot_map, plots_to_visit, remaining, [])
  |> list.reverse
}

/// Recursive implementation of `find_regions`.
fn find_regions_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  plots_to_visit: List(grid2d.Index2D),
  remaining: Region,
  regions: List(Region),
) -> List(Region) {
  case plots_to_visit {
    // Base case. If there are no more plots to visit, return the list
    // of regions.
    [] -> regions

    // If there are still plots to visit, though...
    [next_idx, ..rest] ->
      case set.contains(remaining, next_idx) {
        // If we've already added this plot to a region, skip it.
        False -> find_regions_go(plot_map, rest, remaining, regions)

        // Otherwise, build a new region starting at this plot's index, drop
        // all the plot indices in its region from the set of all plots to
        // check, add the new region to the list of regions, then keep going.
        True -> {
          let region = build_region(plot_map, next_idx)
          let next_remaining = set.difference(remaining, region)
          find_regions_go(plot_map, rest, next_remaining, [region, ..regions])
        }
      }
  }
}

/// Gather the label for each region so Part 2 has quick access to both the
/// plots and the crop type they contain. This function basically just wraps
/// `find_regions`, uses one index from each region to grab a label from the
/// `plot_map`, then attaches that label to the region. There's probably a 
/// cleaner way to implement this, but I didn't do that. :P
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
