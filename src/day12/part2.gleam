import common/grid2d
import day12/day12.{
  type Input, type Output, type Region, find_regions, input_path,
}
import day12/parse
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set

/// Directions used to walk the border when counting sides.
pub type Direction {
  North
  East
  South
  West
}

/// Identify an edge by the plot it belongs to and which side is exposed.
pub type Edge =
  #(grid2d.Index2D, Direction)

/// Translate a facing into the offset required to inspect the neighbor.
fn to_offset(direction: Direction) -> grid2d.Offset2D {
  case direction {
    East -> grid2d.Offset2D(0, 1)
    North -> grid2d.Offset2D(-1, 0)
    South -> grid2d.Offset2D(1, 0)
    West -> grid2d.Offset2D(0, -1)
  }
}

/// Provide a stable sort key so edges are grouped by direction first.
fn sort_order(direction: Direction) -> Int {
  case direction {
    North -> 1
    East -> 2
    South -> 3
    West -> 4
  }
}

/// The difference between an Edge and a perimeter count is that the Edge keeps
/// track of the specific side of the plot that should be separated from
/// another region. This function returns a list of the [Edge]s for the region.
fn find_edges_of_region(region: Region) -> List(Edge) {
  // Inner helper to identify which directions from the plot at `idx` represent
  // a border with either another region or the edge of the map.
  let directions_with_edge = fn(idx) {
    list.fold([North, South, East, West], [], fn(acc, direction) {
      let neighbor_idx = grid2d.apply_offset(idx, to_offset(direction))
      case set.contains(region.plots, neighbor_idx) {
        True -> acc
        False -> [direction, ..acc]
      }
    })
  }

  set.to_list(region.plots)
  |> list.fold([], fn(acc, idx) {
    directions_with_edge(idx)
    |> list.map(fn(edge) { #(idx, edge) })
    |> list.append(acc)
  })
}

/// Comparator to use when sorting [Edge]s. Edges on different faces of a 
/// plot (by cardinal direction) are sorted into groups. Sorting is then
/// row -> column for North- and South-facing edges, column -> row for 
/// East- and West-facing edges.
fn edge_compare(edge1: Edge, edge2: Edge) -> order.Order {
  let #(grid2d.Index2D(r1, c1), d1) = edge1
  let #(grid2d.Index2D(r2, c2), d2) = edge2

  let direction_order = int.compare(sort_order(d1), sort_order(d2))
  let row_order = int.compare(r1, r2)
  let col_order = int.compare(c1, c2)

  // Sorting is by direction first, then either:
  // - row then column for North or South
  // - column then row for East or West
  order.break_tie(direction_order, case d1 {
    North | South -> order.break_tie(row_order, col_order)
    East | West -> order.break_tie(col_order, row_order)
  })
}

/// Determine if two edges are part of the same straight side.
fn is_contiguous(edge1: Edge, edge2: Edge) -> Bool {
  let #(grid2d.Index2D(r1, c1), d1) = edge1
  let #(grid2d.Index2D(r2, c2), d2) = edge2

  case d1 == d2 {
    True ->
      case d1 {
        // North- and South-facing edges are contiguous if they are on the same
        // row and are in adjacent columns.
        North | South -> r1 == r2 && int.absolute_value(c1 - c2) == 1

        // East- and West-facing edges are contiguous if they are on the same
        // column and are in adjacent rows.
        East | West -> c1 == c2 && int.absolute_value(r1 - r2) == 1
      }
    False -> False
  }
}

/// Once sorted, walk the edges and bump the count whenever two neighbors
/// are not part of the same continuous side.
fn count_sides_of_region(region: Region) -> Int {
  // Inner helper to increase the accumulator if a corner is encountered
  // when tracing a set of edges.
  let increment_if_corner = fn(acc, edge_pair) {
    let #(edge1, edge2) = edge_pair
    case is_contiguous(edge1, edge2) {
      False -> acc + 1
      True -> acc
    }
  }

  // If there are any edges in the list of edges, count the number of sides
  // by identifying where each side ends.
  case find_edges_of_region(region) {
    [] -> 0
    edges ->
      edges
      |> list.sort(edge_compare)
      |> list.window_by_2
      |> list.fold(1, increment_if_corner)
  }
}

/// Calculate the price of a region as the number of sides of the region times
/// the area of the region.
fn calculate_price(region: Region) -> Int {
  let sides = count_sides_of_region(region)
  let area = set.size(region.plots)
  sides * area
}

/// For each region, collect its exposed edges, group them into distinct
/// sides, multiply by the region's area, then sum those prices across the
/// map for the final total.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let result =
    input
    |> find_regions
    |> list.map(calculate_price)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  input_path |> parse.read_input |> solve |> echo
}
