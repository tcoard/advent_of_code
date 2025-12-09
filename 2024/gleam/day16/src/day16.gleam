import gleam/bool
import gleam/int
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt, Lt}
import gleam/result
import gleam/string
import simplifile

// get all neighboors, go to all valid neighboors marking current location dir
// for each, when at neighboor, mark
// current spot and repeast

const infinity = 4_294_967_296

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


fn dir_to_char(dir: Direction) ->  String {
  case dir {
    North ->  "^"
    East ->  ">"
    South ->  "V"
    West ->  "<"
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

fn find_start(grid: Grid) -> #(Coord, Direction) {
  let coord = grid
  |> dict.to_list
  |> find_start_loop
  #(coord, East)
}

fn find_start_loop(grid_list: List(#(Coord, String))) -> Coord {
  case grid_list {
    [#(pos, val), ..rest] ->
      case val == "S" {
        True -> pos
        False -> find_start_loop(rest)
      }
    [] -> panic as "could not find start"
  }
}

// TODO use dir_delta
fn neighbors(coord: Coord) -> List(#(Coord, Direction)){
  [
    #(#(coord.0, coord.1 - 1), North),
    #(#(coord.0 + 1, coord.1), East),
    #(#(coord.0, coord.1 + 1), South),
    #(#(coord.0 - 1, coord.1), West),
  ]
}

fn calc_next_pos(pos: Coord, dir: Direction) -> Coord {
  let #(x, y) = pos
  let #(x_delta, y_delta) = dir_delta(dir)
  #(x + x_delta, y + y_delta)
}

fn move(grid: Grid, pos: Coord, dir: Direction) -> Grid {
  let grid = dict.insert(grid, pos, "X")
  let new_pos = calc_next_pos(pos, dir)
  case dict.get(grid, new_pos) {
    Ok("#") -> move(grid, calc_next_pos(pos, turn_90(dir)), turn_90(dir))
    Ok(_) -> move(grid, new_pos, dir)
    Error(_) -> grid
  }
}


fn move_loop(grid: Grid, pos: Coord, dir: Direction, score: Int) {
  neighbors(pos)
  |> list.map(fn (neighbor)
   {
    let #(next_pos, next_dir) = neighbor
    case dict.get(grid, next_pos) {
      Ok(char) -> case char {
        "." -> {
          let turn_score = case next_dir != dir {
            True -> 1000
            False -> 0
          }
          let grid = dict.insert(grid, pos, dir_to_char(next_dir))
          let assert Ok(new_score) = move_loop(grid, next_pos, next_dir, score + turn_score + 1)
          |> list.sort(by: int.compare)
          |> list.first
          new_score
        }
        "E" -> score
        _ -> infinity
      }
      Error(_) -> infinity
    }

  })
  // get the dir, grid, pos of neighbor that was shortest?

}

fn part1(grid: Grid) {
  let #(pos, dir) = find_start(grid)
  move_loop(grid, pos, dir, infinity)
  // |> dict.values
  // |> list.filter(fn(x) { x == "X" })
  // |> list.length
}


// fn part2(grid: Grid) {
//   let #(pos, dir) = find_guard(grid)
//   move_guard(grid, pos, dir)
//   |> dict.to_list
//   |> list.filter(fn(coord_val) { coord_val.1 == "X" })
//   // make a copy of the grid, replacing one X entry with an # in each one.
//   |> list.fold([], fn(acc, entry) {
//     let #(curr_pos, _) = entry
//     case pos != curr_pos {
//       True -> [dict.insert(grid, curr_pos, "#"), ..acc]
//       False -> acc
//     }
//   })
  // |> list.map(infinite_check(_, pos, dir, 0))
  // |> list.filter(fn(x) { x })
  // |> list.length
// }

pub fn main() {
  let filepath = "../../data/day16_test.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let grid = parse_to_grid(input)

  part1(grid) |> io.debug
  // part2(grid) |> io.debug
  //|> io.debug
}

