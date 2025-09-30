import common/grid2d
import day12/day12.{type Input, type Output}
import day12/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string

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
  region: #(UtfCodepoint, List(grid2d.Index2D)),
) -> List(Edge) {
  let #(label, indices) = region
  list.fold(indices, [], fn(acc, idx) {
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
    #(_, d1), #(_, d2) -> False
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
) -> List(#(UtfCodepoint, List(grid2d.Index2D))) {
  let plots_to_visit = dict.to_list(plot_map)
  let remaining = plot_map |> dict.keys |> set.from_list
  find_regions_go(plot_map, plots_to_visit, remaining, [])
  |> list.reverse
}

fn find_regions_go(
  plot_map: grid2d.Grid2D(UtfCodepoint),
  plots_to_visit: List(#(grid2d.Index2D, UtfCodepoint)),
  remaining: set.Set(grid2d.Index2D),
  regions: List(#(UtfCodepoint, List(grid2d.Index2D))),
) -> List(#(UtfCodepoint, List(grid2d.Index2D))) {
  case plots_to_visit {
    [] -> regions
    [#(next_idx, next_label), ..rest] ->
      case set.contains(remaining, next_idx) {
        False -> find_regions_go(plot_map, rest, remaining, regions)
        True -> {
          let region_set = build_region_containing(plot_map, next_idx)
          let next_remaining = set.difference(remaining, region_set)
          let region = #(next_label, set.to_list(region_set))
          find_regions_go(plot_map, rest, next_remaining, [region, ..regions])
        }
      }
  }
}

pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let result =
    find_regions(input)
    |> list.map(fn(region) {
      let edges = find_edges_of_region(input, region)
      let sides = count_sides(edges)
      let area = list.length(region.1)
      sides * area
    })
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  day12.input_path |> parse.read_input |> solve |> io.debug
}
