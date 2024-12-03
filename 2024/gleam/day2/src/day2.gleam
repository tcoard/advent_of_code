import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_reports(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.filter(fn(x) { !string.is_empty(x) })
  |> list.map(fn(x) {
    x
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
}

fn check_status(report_statuses: List(#(Bool, Bool))) -> Bool {
  let assert Ok(#(first_incr_status, _)) = list.first(report_statuses)
  report_statuses
  |> list.all(fn(a_b) {
    let #(a, b) = a_b
    a == first_incr_status && b == True
  })
}

fn is_report_safe(report: List(Int)) {
  report
  |> list.window_by_2
  |> list.map(fn(a_b) {
    let #(a, b) = a_b
    let incrementing = a < b
    let diff = int.absolute_value(a - b)
    let diff_is_safe = diff >= 1 && diff <= 3
    #(incrementing, diff_is_safe)
  })
  |> check_status
}

fn part1(reports: List(List(Int))) {
  reports
  |> list.filter(is_report_safe)
  |> list.length
}

fn part2(reports: List(List(Int))) {
  // list.count(reports, is_report_safe)
  reports
  |> list.filter(fn(line) {
    list.any(list.combinations(line, list.length(line) - 1), is_report_safe)
  })
  |> list.length
}

pub fn main() {
  let filepath = "../../data/day2.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let reports = parse_reports(input)
  part1(reports) |> io.debug
  part2(reports) |> io.debug
}
