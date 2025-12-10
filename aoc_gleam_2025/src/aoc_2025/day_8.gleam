import gleam/dict
import gleam/bool
import gleam/set.{type Set}
import gleam/float
import gleam/int
import gleam/list
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

pub fn distance(p: Coord, q: Coord) -> Float{
  let assert Ok(d) =
    [p.x -. q.z, p.y -. q.y, p.z -. q.z]
    |> list.filter_map(float.power(_, 2.0))
    |> float.sum
    |> float.square_root
  d
}

// node coord, connection: set(coord)

pub fn idk(p: Coord, q: Coord, junctions: List(Set(Coord)), i: Int){
  let new_junct = set.from_list([p, q])
  use <- bool.guard(when: i == 10, return: junctions)
  junctions
  |> list.map(fn(junc) {
    case set.contains(junc, p) || set.conatains(junc, q) {

    }
  })
}

pub fn pt_1(coords: List(Coord)) {
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
}

pub fn pt_2(coords: List(Coord)) {
  todo as "part 2 not implemented"
}
