import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match, Match}
import simplifile

fn part1(input) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(input, with: re)
  |> parse(True, 0)
}

fn part2(input) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  regexp.scan(input, with: re)
  |> parse(True, 0)
}

fn parse(matches: List(Match), do: Bool, acc: Int) {
  case matches {
    [] -> acc
    [Match("do()", []), ..rest] -> parse(rest, True, acc)
    [Match("don't()", []), ..rest] -> parse(rest, False, acc)
    [Match(_, [Some(a), Some(b)]), ..rest] ->
      case do {
        True ->
          parse(
            rest,
            do,
            acc + { list.filter_map([a, b], with: int.parse) |> int.product },
          )
        False -> parse(rest, do, acc)
      }
    _ -> panic
  }
}

pub fn main() {
  let filepath = "../../data/day3.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  part1(input) |> io.debug
  part2(input) |> io.debug
}
