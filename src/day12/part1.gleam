import common/grid2d
import day12/day12.{
  type Input, type Output, type Region, find_regions, input_path,
}
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

fn calculate_region_price(region: Region, perimeters: Perimeters) -> Int {
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
  input_path |> parse.read_input |> solve |> io.debug
}
