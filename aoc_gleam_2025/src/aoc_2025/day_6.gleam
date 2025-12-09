import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  let #(number_lines, ops_line) = list.split(lines, list.length(lines) - 1)

  let nums =
    list.map(number_lines, fn(line) {
      line
      |> string.split(" ")
      |> list.fold([], fn(acc, num) {
        case int.parse(num) {
          Ok(num) -> [num, ..acc]
          Error(_) -> acc
        }
      })
      |> list.reverse
    })
    |> list.transpose

  let assert [ops_line] = ops_line
  let ops = ops_line |> string.split(" ") |> list.filter(fn(op) { op != "" })

  list.zip(nums, ops)
  |> list.map(do_math)
  |> int.sum
}

pub fn do_math(input: #(List(Int), String)) -> Int {
  let #(nums, op) = input
  case op {
    "*" -> list.fold(nums, 1, int.multiply)
    "+" -> list.fold(nums, 0, int.add)
    _ -> panic
  }
}

pub fn idk(input: List(List(String)), current_nums, all) -> List(List(Int)) {
  case input {
    [] -> [current_nums, ..all]
    [[], ..rest] -> idk(rest, [], [current_nums, ..all])
    [digits, ..rest] -> {
      let assert Ok(num) = int.parse(string.join(digits, ""))
      idk(rest, [num, ..current_nums], all)
    }
  }
}

pub fn pt_2(input: String) {
  let lines =
    input
    // |> string.trim
    |> string.split("\n")

  let #(number_lines, ops_line) = list.split(lines, list.length(lines) - 1)

  let nums =
    number_lines
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(list.filter(_, fn(x) { x != " " }))
    |> idk([], [])
    |> list.reverse

  let assert [ops_line] = ops_line
  let ops = ops_line |> string.split(" ") |> list.filter(fn(op) { op != "" })

  list.zip(nums, ops)
  |> list.map(do_math)
  |> int.sum
}
