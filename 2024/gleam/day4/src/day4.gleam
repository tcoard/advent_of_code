import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/order.{type Order, Gt, Lt}
import gleam/string
import simplifile

const xmas = "XMAS"

const mas = "MAS"

pub type Coord =
  #(Int, Int)

pub type Grid =
  Dict(Coord, String)

pub type Direction {
  Vericle
  Horizontal
  Backslash
  ForwardSlash
}

fn direction_modifier(dir: Direction) -> #(Int, Int) {
  case dir {
    Vericle -> #(0, 1)
    Horizontal -> #(1, 0)
    Backslash -> #(1, 1)
    ForwardSlash -> #(-1, 1)
  }
}

fn parse(input: String) -> Grid {
  input
  |> string.split("\n")
  |> list.filter(fn(x) { !string.is_empty(x) })
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, x) { #(#(x, y), char) })
  })
  |> list.flatten
  |> dict.from_list
}

fn part1(grid: Grid) {
  grid
  |> dict.keys
  |> list.map(get_combos(grid, _))
  |> list.flatten
  |> list.length
}

fn part2(grid: Grid) {
  grid
  |> dict.keys
  |> list.map(find_x(grid, _))
  |> list.filter(fn(x) { list.length(x) == 2 })
  |> list.length
}

@deprecated("Just used for debugging")
fn order_coord(a: Coord, b: Coord) -> Order {
  let #(ax, ay) = a
  let #(bx, by) = b
  use <- bool.guard(when: ax > bx, return: Gt)
  use <- bool.guard(when: ax < bx, return: Lt)
  use <- bool.guard(when: ay > by, return: Gt)
  use <- bool.guard(when: ay < by, return: Lt)
  panic as "grid was not parsed correctly"
}

fn find_x(grid: Grid, pos) {
  let #(x, y) = pos
  list.map([Backslash, ForwardSlash], fn(dir) {
    let extra_jump = case dir {
      ForwardSlash -> 2
      Backslash -> 0
      _ -> panic
    }
    list.range(0, 2)
    |> list.fold_until([], fn(acc, i) {
      let #(x_delta, y_delta) = direction_modifier(dir)
      case
        dict.get(grid, #(x + extra_jump + { i * x_delta }, y + { i * y_delta }))
      {
        Ok(char) -> Continue([char, ..acc])
        Error(_) -> Stop([""])
      }
    })
    |> string.join("")
  })
  |> list.filter(fn(str) { str == mas || str == string.reverse(mas) })
}

fn get_combos(grid: Grid, pos) {
  let #(x, y) = pos
  list.map([Vericle, Horizontal, Backslash, ForwardSlash], fn(dir) {
    list.range(0, 3)
    |> list.fold_until([], fn(acc, i) {
      let #(x_delta, y_delta) = direction_modifier(dir)
      case dict.get(grid, #(x + { i * x_delta }, y + { i * y_delta })) {
        Ok(char) -> Continue([char, ..acc])
        Error(_) -> Stop([""])
      }
    })
    |> string.join("")
  })
  |> list.filter(fn(str) { str == xmas || str == string.reverse(xmas) })
}

pub fn main() {
  let filepath = "../../data/day4.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let grid = parse(input)
  part1(grid) |> io.debug
  part2(grid) |> io.debug
}
