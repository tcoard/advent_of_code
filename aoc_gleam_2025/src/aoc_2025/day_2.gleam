import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split(",")
  |> list.map(fn(x) {
    let #(start, end) = format_range(x)
    list.range(start, end)
    |> list.map(calc_dupes)
    |> int.sum
  })
  |> int.sum
}

pub fn calc_dupes(num: Int) {
  let id = int.to_string(num)
  let len = string.length(id)
  case len % 2 == 0 {
    True -> {
      case string.slice(id, 0, len / 2) == string.slice(id, len / 2, len) {
        True -> num
        False -> 0
      }
    }
    False -> 0
  }
}

pub fn format_range(range: String) -> #(Int, Int) {
  let assert Ok(#(a, b)) = string.split_once(range, "-")
  let assert Ok(a) = int.parse(a)
  let assert Ok(b) = int.parse(b)
  // idk if this is needed
  let start = int.min(a, b)
  let end = int.max(a, b)
  #(start, end)
}

pub fn pt_2(input: String) {
  input
  |> string.split(",")
  |> list.map(fn(x) {
    let #(start, end) = format_range(x)
    list.range(start, end)
    |> list.filter(fn(x) { x > 9 })
    |> list.map(calc_dupes_2)
    |> int.sum
  })
  |> int.sum
}

pub fn chunk_dups(chunk: Int, data: List(String)) -> Int {
  list.sized_chunk(data, chunk)
  |> list.unique
  |> list.length
}

pub fn has_dup(chunk_sizes: List(Int), data: List(String)) -> Bool {
  case chunk_sizes {
    [chunk, ..rest] -> {
      case chunk_dups(chunk, data) {
        1 -> True
        _ -> has_dup(rest, data)
      }
    }
    [] -> False
  }
}

pub fn calc_dupes_2(num: Int) {
  let id = int.to_string(num)
  let len = string.length(id)
  let chunk_sizes = list.range(1, len / 2)
  case has_dup(chunk_sizes, string.to_graphemes(id)) {
    True -> num
    False -> 0
  }
}
