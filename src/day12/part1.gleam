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

/// For each plot, track how many edges are exposed to the outside world.
/// The perimeter of any plot is the number of sides that touch either 
/// a different kind of plot or the edge of the grid.
pub type Perimeters =
  grid2d.Grid2D(Int)

/// Count the exposed edges for every plot in the field so we can later price
/// the whole region. Provide the number of exposed sides in a convenient
/// lookup by index.
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

/// The price is the classic "area × perimeter" metric from the puzzle.
fn calculate_region_price(region: Region, perimeters: Perimeters) -> Int {
  // Area is just the number of plots in the region...
  let area = set.size(region)

  // ...and perimeter is the sum of the perimeters of all the plots in 
  // the region.
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

/// Build a perimeter map once, flood-fill each region, price the region by
/// `area × perimeter`, then add every region's price together for the final
/// answer.
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
