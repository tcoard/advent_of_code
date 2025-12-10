import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list.{type ContinueOrStop, Continue, Stop}
import gleam/set.{type Set}
import gleam/string

pub type Coord {
  Coord(x: Float, y: Float, z: Float)
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [x, y, z] =
      line
      |> string.split(",")
      |> list.filter_map(int.parse)
      |> list.map(int.to_float)
    Coord(x:, y:, z:)
  })
}

pub fn distance(p: Coord, q: Coord) -> Float {
  [p.x -. q.x, p.y -. q.y, p.z -. q.z]
  |> list.filter_map(float.power(_, 2.0))
  |> float.sum
  // isn't needed
  // |> float.square_root
}

// node coord, connection: set(coord)

pub fn merge_circuits(
  p: Coord,
  q: Coord,
  circuits: List(Set(Coord)),
) -> List(Set(Coord)) {
  let new_circ = set.from_list([p, q])
  case list.partition(circuits, fn(circ) { !set.is_disjoint(circ, new_circ) }) {
    #([one], rest) -> [set.union(one, new_circ), ..rest]
    #([one, two], rest) -> [set.union(one, two) |> set.union(new_circ), ..rest]
    #([], rest) -> [new_circ, ..rest]
    _ -> panic
  }
}

pub fn pt_1(coords: List(Coord)) {
  let pairs =
    coords
    |> list.combination_pairs
    |> list.map(fn(p_q) {
      let #(p, q) = p_q
      #(p_q, distance(p, q))
    })
    |> list.sort(fn(coord_pair1, coord_pair2) {
      let #(_coords1, d1) = coord_pair1
      let #(_coords2, d2) = coord_pair2
      float.compare(d1, d2)
    })
    |> list.take(1000)

  list.fold(pairs, [], fn(acc, coord_pair) {
    let #(#(p, q), _d) = coord_pair
    merge_circuits(p, q, acc)
  })
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

pub fn merge_circuits_2(
  p: Coord,
  q: Coord,
  circuits: List(Set(Coord)),
) -> List(Set(Coord)) {
  // need to save first input that didnt change the list
  let new_circ = set.from_list([p, q])
  case list.partition(circuits, fn(circ) { !set.is_disjoint(circ, new_circ) }) {
    // #([rest], []) -> {
    //   [rest]
    // }
    #([one], rest) -> [set.union(one, new_circ), ..rest]
    #([one, two], rest) -> [set.union(one, two) |> set.union(new_circ), ..rest]
    #([], rest) -> [new_circ, ..rest]
    _ -> panic
  }
}

pub fn pt_2(coords: List(Coord)) {
  let pairs =
    coords
    |> list.combination_pairs
    |> list.map(fn(p_q) {
      let #(p, q) = p_q
      #(p_q, distance(p, q))
    })
    |> list.sort(fn(coord_pair1, coord_pair2) {
      let #(_coords1, d1) = coord_pair1
      let #(_coords2, d2) = coord_pair2
      float.compare(d1, d2)
    })
  // |> list.take(1000)

  list.fold(pairs, [], fn(acc, coord_pair) {
    let #(#(p, q), _d) = coord_pair
    let new = merge_circuits_2(p, q, acc)
    case new == acc {
      False -> echo coord_pair
      True -> echo #(#(Coord(0.0, 0.0, 0.0), Coord(0.0, 0.0, 0.0)), 0.0)
    }
    new
  })
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, int.multiply)
}
