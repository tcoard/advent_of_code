import gleam/list
import gleam/dict
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) {
  let parsed_lines = to_grid(input)

  let assert [start, ..rest] = parsed_lines
  // let assert Ok(start) = list.first(start)
  run_beam(start, rest, 0)
  |> echo
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
    [x, ..rest] -> splits_to_next(rest, set.union(splitted, set.from_list([x-1, x+1])))
    [] -> splitted
  }
}

pub fn run_beam(xs: Set(Int), grid: List(Set(Int)), counter: Int) {
  case grid {
    [next, ..rest] ->{
      let splits = set.intersection(xs, next)
      let counter = counter + set.size(splits)
      let no_split = set.difference(xs, next)

      let next_xs = splits_to_next(set.to_list(splits), no_split)
      run_beam(next_xs, rest, counter)
    }
    [] -> counter
  }
}


pub fn splits_to_next_2(splits: List(Int), splitted: Set(Int)) {
  case splits {
    [x, ..rest] -> splits_to_next(rest, set.union(splitted, set.from_list([x-1, x+1])))
    [] -> splitted
  }
}

pub fn run_beam_2(x: Int, grid: List(List(Int))) {
  case grid {
    [next, ..rest] ->{
      case list.contains(next, x) {
        True -> run_beam_2(x - 1, rest) + run_beam_2(x + 1, rest)
        False -> run_beam_2(x, rest)
      }
    }
    [] -> 1
  }
}

pub fn to_grid_2(input: String) {
  let lines = input |> string.split("\n")
  {
    use line <- list.map(lines)
    use acc, char, x <- list.index_fold(string.to_graphemes(line), dict.new())
    case char {
      "." -> dict.insert(acc, x, 0)
      "S" -> dict.insert(acc, x, 1)
      _ -> acc
    }
  }
}

pub fn pt_2(input: String) {
  // #(pos, num of times it was gotten to)
  // at the end do multiplacation
  let parsed_lines = to_grid_2(input)
  parsed_lines
  // let assert [start, ..rest] = parsed_lines
  // let assert Ok(start) = list.first(start)
  // run_beam_2(start, rest)
  // |> echo
}
