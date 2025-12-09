import gleam/int
import gleam/list
import gleam/string

pub type Range {
  Range(start: Int, end: Int)
}

pub type Parsed {
  Parsed(ranges: List(Range), ingredients: List(Int))
}

pub fn parse(input: String) -> Parsed {
  let assert [ranges, ingredients] = string.split(input, "\n\n")

  let ranges =
    string.split(ranges, "\n")
    |> list.map(fn(line) {
      let assert [start, end] = string.split(line, "-")
      let assert Ok(start) = int.parse(start)
      let assert Ok(end) = int.parse(end)
      Range(start:, end:)
    })

  let ingredients =
    string.split(ingredients, "\n")
    |> list.map(fn(ing) {
      let assert Ok(ing) = int.parse(ing)
      ing
    })
  Parsed(ranges, ingredients)
}

pub fn pt_1(input: Parsed) {
  {
    use ing <- list.map(input.ingredients)
    use acc, range <- list.fold_until(input.ranges, 0)
    case range.start <= ing && ing <= range.end {
      True -> list.Stop(acc + 1)
      False -> list.Continue(acc)
    }
  }
  |> int.sum
}

pub fn traverse_ranges(ranges: List(Range), i: Int, count: Int) {
  case ranges {
    [range, ..rest] -> {
      case i {
        i if i < range.start ->
          traverse_ranges(
            rest,
            range.end + 1,
            { range.end - range.start } + count + 1,
          )
        i if i > range.end -> traverse_ranges(rest, i, count)
        i -> traverse_ranges(rest, range.end + 1, { range.end - i } + count + 1)
      }
    }
    [] -> count
  }
}

pub fn pt_2(input: Parsed) {
  input.ranges
  |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
  |> traverse_ranges(0, 0)
}
