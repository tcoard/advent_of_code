import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) {
  let parsed_lines = to_grid(input)

  let assert [start, ..rest] = parsed_lines
  // let assert Ok(start) = list.first(start)
  run_beam(start, rest, 0)
}

pub fn to_grid(input: String) {
  let lines = input |> string.split("\n")
  {
    use line <- list.map(lines)
    use acc, char, x <- list.index_fold(string.to_graphemes(line), set.new())
    case char == "." {
      True -> acc
      False -> set.insert(acc, x)
    }
  }
}

pub fn splits_to_next(splits: List(Int), splitted: Set(Int)) {
  case splits {
    [x, ..rest] ->
      splits_to_next(rest, set.union(splitted, set.from_list([x - 1, x + 1])))
    [] -> splitted
  }
}

pub fn run_beam(xs: Set(Int), grid: List(Set(Int)), counter: Int) {
  case grid {
    [next, ..rest] -> {
      let splits = set.intersection(xs, next)
      let counter = counter + set.size(splits)
      let no_split = set.difference(xs, next)

      let next_xs = splits_to_next(set.to_list(splits), no_split)
      run_beam(next_xs, rest, counter)
    }
    [] -> counter
  }
}

pub fn on(
  outer_fn: fn(mid, mid) -> out,
  inner_fn: fn(in) -> mid,
  a: in,
  b: in,
) -> out {
  outer_fn(inner_fn(a), inner_fn(b))
}

pub fn run_beam_2(xs: Dict(Int, Int), grid: List(Dict(Int, Int))) {
  case grid {
    [next, ..rest] -> {
      // do I need to limit bounds to 0, max?
      let get_keys_as_set = fn(x) { set.from_list(dict.keys(x)) }
      on(set.intersection, get_keys_as_set, xs, next)
      |> set.fold(xs, fn(acc, split) {
        let assert Ok(prev_val) = dict.get(acc, split)
        dict.from_list([
          #(split + 1, prev_val),
          #(split - 1, prev_val),
        ])
        |> dict.combine(acc, int.add)
        |> dict.drop([split])
      })
      |> run_beam_2(rest)
    }
    [] -> {
      xs
      |> dict.values
      |> int.sum
    }
  }
}

pub fn to_grid_2(input: String) {
  let lines = input |> string.split("\n")
  {
    use line <- list.map(lines)
    use acc, char, x <- list.index_fold(string.to_graphemes(line), dict.new())
    case char {
      "^" -> dict.insert(acc, x, 0)
      "S" -> dict.insert(acc, x, 1)
      _ -> acc
    }
  }
}

pub fn pt_2(input: String) {
  let parsed_lines = to_grid_2(input)

  let assert [start, ..rest] = parsed_lines
  run_beam_2(start, rest)
}
