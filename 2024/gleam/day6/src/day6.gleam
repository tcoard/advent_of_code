import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import gleam/option.{type Option, None, Some}
import simplifile

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



fn guard_dir(guard: String) -> Option(Direction) {
  case guard {
    "^" -> Some(North)
    ">" -> Some(East)
    "V" -> Some(South)
    "<" -> Some(West)
    _ -> None
  }
}

fn find_guard(position: Coord, grid: Grid) -> #(Direction, Coord){
  grid
  dict.to_list
  // let #(x, y) = position
  // let curr_char = dict.get(grid, position)

  // use <- bool.guard(when: curr_char == Error(Nil), )
  // case dict.get(grid, position) {
  //   Ok(x) -> case guard_dir(x) {
  //     Some(Direction(dir)) -> #(dir, position)
  //     None -> find_guard
  //   }
  //   Error(_) -> case find_guard(#(x+1), grid) {
  //     Direction(dir) -> dir
  //     _ -> North // should this be optional/error?
  //   }
  // }

}


fn find_guard(grid: Grid) {
  case
}


fn move_guard(grid: Grid) {
  guard = 
}

pub fn main() {
  let filepath = "../../data/day6_test.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
}
