import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt, Lt}
import gleam/result
import gleam/string
import simplifile

const max_iterations = 10000

pub type Coord =
  #(Int, Int)

pub type Grid =
  Dict(Coord, String)

pub type Direction {
  North
  East
  South
  West
}

fn parse_to_grid(input: String) -> Grid {
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

fn guard_dir(guard: String) -> Option(Direction) {
  case guard {
    "^" -> Some(North)
    ">" -> Some(East)
    "V" -> Some(South)
    "<" -> Some(West)
    _ -> None
  }
}

fn turn_90(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn dir_delta(dir: Direction) -> Coord {
  case dir {
    North -> #(0, -1)
    East -> #(1, 0)
    South -> #(0, 1)
    West -> #(-1, 0)
  }
}

fn find_guard(grid: Grid) -> #(Coord, Direction) {
  grid
  |> dict.to_list
  |> find_guard_loop
}

fn find_guard_loop(grid_list: List(#(Coord, String))) -> #(Coord, Direction) {
  case grid_list {
    [#(pos, val), ..rest] ->
      case guard_dir(val) {
        Some(dir) -> #(pos, dir)
        None -> find_guard_loop(rest)
      }
    [] -> panic as "could not find guard"
  }
}

fn calc_next_pos(pos: Coord, dir: Direction) -> Coord {
  let #(x, y) = pos
  let #(x_delta, y_delta) = dir_delta(dir)
  #(x + x_delta, y + y_delta)
}

fn move_guard(grid: Grid, pos: Coord, dir: Direction) -> Grid {
  let grid = dict.insert(grid, pos, "X")
  let new_pos = calc_next_pos(pos, dir)
  case dict.get(grid, new_pos) {
    Ok("#") -> move_guard(grid, calc_next_pos(pos, turn_90(dir)), turn_90(dir))
    Ok(_) -> move_guard(grid, new_pos, dir)
    Error(_) -> grid
  }
}

fn part1(grid: Grid) -> Int {
  let #(pos, dir) = find_guard(grid)
  move_guard(grid, pos, dir)
  |> dict.values
  |> list.filter(fn(x) { x == "X" })
  |> list.length
}

fn infinite_check(
  grid: Grid,
  pos: Coord,
  dir: Direction,
  iteration: Int,
) -> Bool {
  use <- bool.guard(when: iteration == max_iterations, return: True)
  let grid = dict.insert(grid, pos, "X")
  let new_pos = calc_next_pos(pos, dir)
  case dict.get(grid, new_pos) {
    Ok("#") ->
      infinite_check(
        grid,
        pos,
        turn_90(dir),
        iteration+1,
      )
    Ok(_) -> infinite_check(grid, new_pos, dir, iteration+1)
    Error(_) -> False
  }
}

fn part2(grid: Grid) {
  let #(pos, dir) = find_guard(grid)
  move_guard(grid, pos, dir)
  |> dict.to_list
  |> list.filter(fn(coord_val) { coord_val.1 == "X" })
  // make a copy of the grid, replacing one X entry with an # in each one.
  |> list.fold([], fn(acc, entry) {
    let #(curr_pos, _) = entry
    case pos != curr_pos {
      True -> [dict.insert(grid, curr_pos, "#"), ..acc]
      False -> acc
    }
  })
  |> list.map(infinite_check(_, pos, dir, 0))
  |> list.filter(fn(x) { x })
  |> list.length
}

pub fn main() {
  let filepath = "../../data/day6.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let grid = parse_to_grid(input)

  part1(grid) |> io.debug
  part2(grid) |> io.debug
  //|> io.debug
}
