import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_reports(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  // |> io.debug
  |> list.filter(fn(x) { !string.is_empty(x) })
  |> list.map(fn(x) {
    x
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
}

fn is_report_safe1(report_statuses: List(#(Bool, Bool))) -> Bool {
  let assert Ok(#(first_incr_status, _)) = list.first(report_statuses)
  report_statuses
  |> list.all(fn(a_b) {
    let #(a, b) = a_b
    a == first_incr_status && b == True
  })
}

fn part1(reports: List(List(Int))) {
  reports
  |> list.map(fn(report) {
    report
    |> list.window_by_2
    |> list.map(fn(a_b) {
      let #(a, b) = a_b
      let incrementing = a < b
      let diff = int.absolute_value(a - b)
      let diff_is_safe = diff >= 1 && diff <= 3
      #(incrementing, diff_is_safe)
    })
    |> is_report_safe1
    |> bool.to_int
  })
  |> int.sum()
}

fn is_report_safe(prev: Int, curr: Int, next: Int) -> Bool {
  // when curr isn't between last and next
  use <- bool.guard(
    when: !{ prev < curr && curr < next || prev > curr && curr > next },
    return: False,
  )
  // use <- bool.guard(when: prev > curr || curr > next && prev < curr || curr < next, return: False)
  let diff = int.absolute_value(curr - next)
  // when diff is too large
  use <- bool.guard(when: diff < 1 || diff > 3, return: False)
  True
}

fn report_fixer(report: List(Int)) -> Bool{
  report_fixer_loop(report, True, False)
}

fn report_fixer_loop(
  report: List(Int),
  is_first: Bool,
  already_removed_one: Bool,
) -> Bool {
  case report {
    [] | [_] | [_, _] -> True
    [prev, curr, next, ..rest] ->
      case is_first {
        True -> {
          let curr = prev
          let next = curr
          case is_report_safe(prev, curr, next) {
            True -> report_fixer_loop(rest, False, False)
            False -> False
          }
          // let prev_is_inc = curr < next
        }
        False ->
          case is_report_safe(prev, curr, next) {
            True -> report_fixer_loop(rest, False, False)
            False -> False
          }
      }
  }
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
  let filepath = "../../data/day2_test.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let reports = parse_reports(input)
  part1(reports) |> io.debug
  reports
  |> list.map(report_fixer)
  |> io.debug
}
