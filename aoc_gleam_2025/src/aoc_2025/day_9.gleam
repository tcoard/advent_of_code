import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn pt_1(input: String) {
  let assert Ok(largest) =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [x, y] = string.split(line, ",") |> list.filter_map(int.parse)
      Coord(x:, y:)
    })
    |> list.combination_pairs
    |> list.map(fn(a_b) {
      let #(a, b) = a_b
      { 1 + int.absolute_value(a.x - b.x) }
      * { 1 + int.absolute_value(a.y - b.y) }
    })
    |> list.sort(int.compare)
    |> list.last
  largest
}

// (x1, y1), (x2, y2)
// if any other coord is in above

pub fn get_inside(
  x: Int,
  y: Int,
  is_inside: Bool,
  last_pos_was_border: Bool,
  inside: Set(Coord),
  max_x: Int,
  max_y: Int,
  border: Set(Coord),
) {
  case y > max_y, x > max_x {
    True, _ -> inside
    // newline
    False, True -> {
      case y % 100 == 0 {
        True -> echo y
        False -> y
      }
      get_inside(0, y + 1, False, False, inside, max_x, max_y, border)
    }
    False, False -> {
      let current_coord = Coord(x, y)
      case set.contains(border, Coord(x, y)), is_inside, last_pos_was_border {
        // staying on border
        True, _, True ->
          get_inside(
            x + 1,
            y,
            True,
            True,
            set.insert(inside, current_coord),
            max_x,
            max_y,
            border,
          )
        // leaving inside
        True, True, _ ->
          get_inside(
            x + 1,
            y,
            False,
            True,
            set.insert(inside, current_coord),
            max_x,
            max_y,
            border,
          )
        // going inside
        True, False, _ ->
          get_inside(
            x + 1,
            y,
            True,
            True,
            set.insert(inside, current_coord),
            max_x,
            max_y,
            border,
          )
        // staying inside
        False, True, _ ->
          get_inside(
            x + 1,
            y,
            True,
            False,
            set.insert(inside, current_coord),
            max_x,
            max_y,
            border,
          )
        // staying outside
        False, False, _ ->
          get_inside(x + 1, y, False, False, inside, max_x, max_y, border)
      }
    }
  }
}

pub fn display_grid(max_x, max_y, coords: Set(Coord)) {
  {
    use y <- list.map(list.range(0, max_y))
    use x <- list.map(list.range(0, max_x))
    case set.contains(coords, Coord(x, y)) {
      True -> "#"
      False -> "."
    }
  }
  // |> list.map(fn(x){ string.join(x, "")})
  |> list.map(string.join(_, ""))
  |> string.join("\n")
  |> io.println
}

pub fn pt_2(input: String) {
  let coords =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [x, y] = string.split(line, ",") |> list.filter_map(int.parse)
      Coord(x:, y:)
    })
  let assert Ok(last) = list.last(coords)
  let coords = [last, ..coords]
  let border =
    coords
    |> list.window_by_2
    |> list.map(fn(start_stop) {
      let #(start, stop) = start_stop
      case start.x == stop.x {
        True ->
          list.range(start.y, stop.y) |> list.map(fn(y) { Coord(start.x, y) })
        False ->
          list.range(start.x, stop.x) |> list.map(fn(x) { Coord(x, start.y) })
      }
    })
    |> list.flatten
    |> set.from_list

  let sorted_x =
    coords
    |> list.map(fn(coord) { coord.x })
    |> list.sort(int.compare)

  let assert Ok(max_x) = list.last(sorted_x)
  let assert Ok(min_x) = list.first(sorted_x)
  let sorted_y =
    coords
    |> list.map(fn(coord) { coord.y })
    |> list.sort(int.compare)
  let assert Ok(max_y) = list.last(sorted_y)
  let assert Ok(min_y) = list.first(sorted_y)
  let inside =
    get_inside(min_x, min_y, False, False, set.new(), max_x, max_y, border)
  // coords
  //   |> list.combination_pairs
  //   |> list.map(fn(a_b) {
  //     let #(a, b) = a_b
  //     let rect_coords = {
  //       use y <- list.flat_map(list.range(a.y, b.y))
  //       use x <- list.map(list.range(a.x, b.x))
  //       Coord(x, y)
  //     }
  //     |> set.from_list
  //     case set.is_subset(rect_coords, inside) {
  //       True -> { 1 + int.absolute_value(a.x - b.x) } * { 1 + int.absolute_value(a.y - b.y) }
  //       False -> 0
  //     }
  //   })
  //   |> list.sort(int.compare)
  //   |> list.last

  // display_grid(max_x, max_y, inside)
  //

  // coords
  // |> list.combination_pairs
  // |> list.map(fn(a_b) {
  //   let #(a, b) = a_b
  //   let area =
  //     { 1 + int.absolute_value(a.x - b.x) }
  //     * { 1 + int.absolute_value(a.y - b.y) }
  //   #(a_b, area)
  // })
  // |> list.sort(fn(coords_dist1, coords_dist2) {
  //   let #(#(_a1, _b1), dist1) = coords_dist1
  //   let #(#(_a2, _b2), dist2) = coords_dist2
  //   int.compare(dist1, dist2)
  // })
}
