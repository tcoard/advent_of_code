import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn format_list(input: List(String)) {
  input
  |> list.filter_map(int.parse)
  |> list.sort(by: int.compare)
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
  list.map2(a, b, fn(x, y) { int.absolute_value(x - y) })
  |> int.sum()
}

pub fn similarity_score(a: List(Int), b: List(Int)) -> Int {
  similarity_score_loop(a, b, 0)
}

fn similarity_score_loop(a: List(Int), b: List(Int), acc: Int) -> Int {
  // the lists are sorted from before, so we can use that
  case a, b {
    [], _ | _, [] -> acc
    [a1, ..], [b1, ..b_rest] if a1 > b1 -> similarity_score_loop(a, b_rest, acc)
    [a1, ..a_rest], [b1, ..] if a1 < b1 -> similarity_score_loop(a_rest, b, acc)
    [a1, ..], [b1, ..b_rest] if a1 == b1 ->
      similarity_score_loop(a, b_rest, acc + a1)
    _, _ -> panic as "error in similarity_score_loop"
  }
}

// @depricated
// fn similarity_score(a: List(Int), b: List(Int)) {
//   let b = bag.from_list(b)
//   list.fold(over: a, from: 0, with: fn(last, curr) {
//     last + curr * bag.copies(b, curr)
//   })
// }

pub fn main() {
  let filepath = "../../data/day1.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let #(a, b) = sep_lists(input)

  // day 1
  compare_lists(a, b) |> io.debug

  // part 2
  similarity_score(a, b) |> io.debug
}
