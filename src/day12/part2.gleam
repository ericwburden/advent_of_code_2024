import common/grid2d
import day12/day12.{type Input, type Output}
import day12/parse
import day12/regions
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set

pub type Direction {
  North
  East
  South
  West
}

pub type Edge =
  #(grid2d.Index2D, Direction)

fn to_offset(direction: Direction) -> grid2d.Offset2D {
  case direction {
    East -> grid2d.Offset2D(0, 1)
    North -> grid2d.Offset2D(-1, 0)
    South -> grid2d.Offset2D(1, 0)
    West -> grid2d.Offset2D(0, -1)
  }
}

fn sort_order(direction: Direction) -> Int {
  case direction {
    North -> 1
    East -> 2
    South -> 3
    West -> 4
  }
}

// fn directions_with_edge(
//   plot_map: grid2d.Grid2D(UtfCodepoint),
//   of_plot: #(grid2d.Index2D, UtfCodepoint),
// ) -> List(Direction) {
//   let #(plot_idx, plot_label) = of_plot
//   list.fold([North, South, East, West], [], fn(acc, direction) {
//     let neighbor_idx = grid2d.apply_offset(plot_idx, to_offset(direction))
//     case grid2d.get(plot_map, neighbor_idx) {
//       Error(_) -> [direction, ..acc]
//       Ok(v) if v != plot_label -> [direction, ..acc]
//       Ok(_) -> acc
//     }
//   })
// }

fn find_edges_of_region(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  region: regions.LabelledRegion,
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

fn edge_compare(edge1: Edge, edge2: Edge) -> order.Order {
  let #(grid2d.Index2D(r1, c1), d1) = edge1
  let #(grid2d.Index2D(r2, c2), d2) = edge2

  // Sorting is by direction first, then either:
  // - row then column for North or South
  // - column then row for East or West
  case d1 == d2 {
    True ->
      case d1 {
        North | South ->
          case int.compare(r1, r2) {
            order.Eq -> int.compare(c1, c2)
            other -> other
          }
        East | West ->
          case int.compare(c1, c2) {
            order.Eq -> int.compare(r1, r2)
            other -> other
          }
      }
    False -> int.compare(sort_order(d1), sort_order(d2))
  }
}

fn is_contiguous(edge1: Edge, edge2: Edge) -> Bool {
  case edge1, edge2 {
    #(grid2d.Index2D(r1, c1), d1), #(grid2d.Index2D(r2, c2), d2) if d1 == d2 ->
      case d1 {
        North | South -> r1 == r2 && int.absolute_value(c1 - c2) == 1
        East | West -> c1 == c2 && int.absolute_value(r1 - r2) == 1
      }
    #(_, _), #(_, _) -> False
  }
}

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

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let result =
    regions.find_labelled_regions(input)
    |> list.map(fn(region) {
      let edges = find_edges_of_region(input, region)
      let sides = count_sides(edges)
      let area =
        region.1
        |> set.size
      sides * area
    })
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  day12.input_path |> parse.read_input |> solve |> io.debug
}
