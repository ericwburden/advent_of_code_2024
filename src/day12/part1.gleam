import common/grid2d
import day12/day12.{
  type Input, type Output, type Region, find_regions, input_path,
}
import day12/parse
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set

/// Count the exposed edges for every plot in the region and sum them to get
/// the total perimeter.
fn calculate_region_perimeter(region: Region) -> Int {
  // Inner helper to identify whether a neighbor at a particular offset
  // is part of the same region as the plot at `idx`.
  let side_exposed = fn(idx, offset) {
    let neighbor = grid2d.apply_offset(idx, offset)
    set.contains(region.plots, neighbor)
  }

  // Inner helper to count the number of neighbors outside the region for 
  // a plot at a given `idx`.
  let count_exposed_sides = fn(idx) {
    list.fold(grid2d.cardinal_offsets, 0, fn(acc, offset) {
      case side_exposed(idx, offset) {
        True -> acc
        False -> acc + 1
      }
    })
  }

  // For each plot in the region, sum the number of exposed sides
  region.plots |> set.to_list |> list.map(count_exposed_sides) |> int.sum
}

/// The price is the classic "area × perimeter" metric from the puzzle.
fn calculate_region_price(region: Region) -> Int {
  // Area is just the number of plots in the region...
  let area = set.size(region.plots)

  // ...and perimeter is the number of exposed edges across the region.
  let perimeter = calculate_region_perimeter(region)

  area * perimeter
}

/// Flood-fill each region, compute its area and perimeter on the fly, price
/// it by `area × perimeter`, then add every region's price together for the
/// final answer.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let result =
    input
    |> find_regions
    |> list.map(calculate_region_price)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  input_path |> parse.read_input |> solve |> io.debug
}
