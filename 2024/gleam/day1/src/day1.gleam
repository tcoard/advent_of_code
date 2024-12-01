import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn format_list(input: List(String)) {
  input
  |> list.map(int.base_parse(_, 10))
  |> result.values
}

fn sep_lists(input: String) -> #(List(Int), List(Int)) {
  let #(a, b) =
    input
    |> string.split("\n")
    |> list.map(string.split_once(_, on: "   "))
    |> result.values
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
  list.fold(over: a, from: 0, with: fn(last, curr) {
    last + curr * list.count(b, fn(i) { i == curr })
  })
}

pub fn main() {
  let filepath = "../../data/day1.txt"
  let assert Ok(input) = read(from: filepath)
  let #(a, b) = sep_lists(input)

  // day 1
  let output = compare_lists(a, b)
  io.debug(output)

  // day 2
  let output = similarity_score(a, b)
  io.debug(output)
}
