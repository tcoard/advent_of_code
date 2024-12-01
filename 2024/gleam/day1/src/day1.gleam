import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import tote/bag

fn format_list(input: List(String)) {
  input
  |> list.filter_map(int.parse)
}

fn sep_lists(input: String) -> #(List(Int), List(Int)) {
  let #(a, b) =
    input
    |> string.split("\n")
    |> list.filter_map(string.split_once(_, on: "   "))
    |> list.unzip
  #(format_list(a), format_list(b))
}

fn compare_lists(a: List(Int), b: List(Int)) -> Int {
  let a = list.sort(a, by: int.compare)
  let b = list.sort(b, by: int.compare)
  list.map2(a, b, fn(x, y) { int.absolute_value(x - y) })
  |> int.sum()
}

fn similarity_score(a: List(Int), b: List(Int)) {
  let b = bag.from_list(b)
  list.fold(over: a, from: 0, with: fn(last, curr) {
    last + curr * bag.copies(b, curr)
  })
}

pub fn main() {
  let filepath = "../../data/day1.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let #(a, b) = sep_lists(input)

  // day 1
  compare_lists(a, b) |> io.debug

  // part 2
  similarity_score(a, b) |> io.debug
}
