import common/grid2d
import day12/day12.{
  type Input, type LabelledRegion, type Output, find_labelled_regions,
  input_path,
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

/// Collect every exposed edge for the region by checking the four neighbors
/// of each plot and keeping the ones that lead outside the region.
fn find_edges_of_region(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  region: LabelledRegion,
) -> List(Edge) {
  let #(label, indices) = region
  set.to_list(indices)
  |> list.fold([], fn(acc, idx) {
    let plot_edge_directions =
      list.fold([North, South, East, West], [], fn(acc, direction) {
        let neighbor_idx = grid2d.apply_offset(idx, to_offset(direction))
        case grid2d.get(plot_map, neighbor_idx) {
          Error(_) -> [direction, ..acc]
          Ok(v) if v != label -> [direction, ..acc]
          Ok(_) -> acc
        }
      })

    let indexed_edges =
      list.map(plot_edge_directions, fn(edge) { #(idx, edge) })
    list.append(indexed_edges, acc)
  })
}

/// Sort edges so contiguous ones sit next to each other for the fold that
/// counts distinct sides.
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
        North | South -> r1 == r2 && int.absolute_value(c1 - c2) == 1
        East | West -> c1 == c2 && int.absolute_value(r1 - r2) == 1
      }
    False -> False
  }
}

/// Once sorted, walk the edges and bump the count whenever two neighbors
/// are not part of the same continuous side.
fn count_sides(edges: List(Edge)) -> Int {
  case edges {
    [] -> 0
    _ ->
      edges
      |> list.sort(edge_compare)
      |> list.window_by_2
      |> list.fold(1, fn(acc, edge_pair) {
        let #(edge1, edge2) = edge_pair
        case is_contiguous(edge1, edge2) {
          False -> acc + 1
          True -> acc
        }
      })
  }
}

fn calculate_price(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  region: LabelledRegion,
) -> Int {
  let sides = plot_map |> find_edges_of_region(region) |> count_sides
  let area = set.size(region.1)
  sides * area
}

/// For each region, collect its exposed edges, group them into distinct
/// sides, multiply by the region's area, then sum those prices across the
/// map for the final total.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let price_fn = fn(region) { calculate_price(input, region) }
  let result =
    find_labelled_regions(input)
    |> list.map(price_fn)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  input_path |> parse.read_input |> solve |> io.debug
}
