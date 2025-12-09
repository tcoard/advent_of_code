import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type Grid =
  Dict(#(Int, Int), Bool)

pub fn pt_1(input: String) {
  input
  |> to_grid
  |> num_adjacent
}

pub fn gen_deltas() -> List(#(Int, Int)) {
  list.combinations([-1, 0, 1], 2)
  |> list.map(list.permutations)
  |> list.flatten
  |> list.map(fn(coord) {
    let assert [x, y] = coord
    #(x, y)
  })
  |> list.append([#(1, 1), #(-1, -1)])
}

pub fn num_adjacent(grid: Grid) -> Int {
  let deltas = gen_deltas()

  use final_count, coord <- list.fold(dict.keys(grid), 0)
  let neighboors = {
    use acc, delta <- list.fold(deltas, 0)
    case dict.get(grid, #(coord.0 + delta.0, coord.1 + delta.1)) {
      Ok(_) -> 1
      Error(Nil) -> 0
    }
    |> int.add(acc)
  }

  case neighboors >= 4 {
    True -> 0
    False -> 1
  }
  |> int.add(final_count)
}

pub fn num_adjacent_2(grid: Grid) -> List(#(Int, Int)) {
  let deltas = gen_deltas()

  use acc, coord <- list.fold(dict.keys(grid), [])
  let neighboors = {
    use neighboors_acc, delta <- list.fold(deltas, 0)
    case dict.get(grid, #(coord.0 + delta.0, coord.1 + delta.1)) {
      Ok(_) -> 1
      Error(Nil) -> 0
    }
    |> int.add(neighboors_acc)
  }

  case neighboors >= 4 {
    True -> acc
    False -> [coord, ..acc]
  }
}

pub fn to_grid(input: String) -> Grid {
  let lines = input |> string.split("\n")
  {
    use line, y <- list.index_map(lines)
    use acc, char, x <- list.index_fold(string.to_graphemes(line), [])
    case char == "@" {
      True -> [#(#(x, y), True), ..acc]
      False -> acc
    }
  }
  |> list.flatten
  |> dict.from_list
}

// pub fn to_grid(input: String) -> Grid {
//   input
//   |> string.split("\n")
//   |> list.index_map(fn(line, y) {
//     list.index_fold(string.to_graphemes(line), [], fn(acc, char, x) {
//       case char == "@" {
//         True -> [#(#(x, y), True), ..acc]
//         False -> acc
//       }
//     })
//   })
//   |> list.flatten
//   |> dict.from_list
// }

pub fn num_adjacent_2_outer(grid: Grid, count: Int) -> Int {
  let to_remove = num_adjacent_2(grid)
  let len = list.length(to_remove)
  case len > 0 {
    True -> num_adjacent_2_outer(dict.drop(grid, to_remove), count + len)
    False -> count
  }
}

pub fn pt_2(input: String) {
  input
  |> to_grid
  |> num_adjacent_2_outer(0)
}
