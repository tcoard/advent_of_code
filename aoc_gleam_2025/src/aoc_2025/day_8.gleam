import gleam/float
import gleam/int
import gleam/list
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

pub fn track_state_change(
  pairs: List(#(#(Coord, Coord), Float)),
  connections: List(Set(Coord)),
  last_change_coords: #(Coord, Coord),
) {
  case pairs {
    [pair, ..rest] -> {
      let #(#(p, q), _d) = pair
      let new = merge_circuits(p, q, connections)
      case new == connections {
        True -> track_state_change(rest, new, last_change_coords)
        False -> track_state_change(rest, new, #(p, q))
      }
    }
    [] -> last_change_coords
  }
}

pub fn pt_2(coords: List(Coord)) {
  let #(p, q) =
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
    |> track_state_change([], #(Coord(0.0, 0.0, 0.0), Coord(0.0, 0.0, 0.0)))
  p.x *. q.x
}
