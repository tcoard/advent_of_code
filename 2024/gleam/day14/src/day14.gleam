import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt, Lt}
import gleam/regexp.{type Match, Match}
import gleam/result
import gleam/string
import simplifile
import tote/bag

const grid_x = 101

const grid_y = 103

pub type Coord =
  #(Int, Int)

pub type Grid =
  Dict(Coord, Option(Robot))

pub type Robot {
  Robot(position: Coord, velocity: Coord)
}

pub type QuadrantCounts {
  QuadrantCounts(q1: Int, q2: Int, q3: Int, q4: Int)
}

fn parse_robots_loop(matches: List(Match), acc: List(Robot)) {
  case matches {
    [] -> acc
    [Match(_, [Some(x1), Some(y1), Some(x_delta), Some(y_delta)]), ..rest] -> {
      let assert Ok(x1) = int.parse(x1)
      let assert Ok(y1) = int.parse(y1)
      let assert Ok(x_delta) = int.parse(x_delta)
      let assert Ok(y_delta) = int.parse(y_delta)
      parse_robots_loop(rest, [
        Robot(position: #(x1, y1), velocity: #(x_delta, y_delta)),
        ..acc
      ])
    }
    _ -> panic
  }
}

fn robots_to_grid(robots: List(Robot)) {
  let robot_bag =
    robots
    |> list.map(fn(robot) { robot.position })
    |> bag.from_list

  list.range(0, grid_y - 1)
  |> list.map(fn(y) {
    list.range(0, grid_x - 1)
    |> list.map(fn(x) {
      bag.copies(of: #(x, y), in: robot_bag) |> int.to_string
    })
    |> string.join(" ")
  })
  |> string.join("\n")
}

fn parse_robots(input: String) -> List(Robot) {
  let assert Ok(re) =
    regexp.from_string("p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)")
  regexp.scan(input, with: re)
  |> parse_robots_loop([])
}

fn move_robot(robot: Robot) {
  let assert Ok(new_x) =
    int.modulo({ robot.position.0 + robot.velocity.0 }, grid_x)
  let assert Ok(new_y) =
    int.modulo({ robot.position.1 + robot.velocity.1 }, grid_y)
  Robot(..robot, position: #(new_x, new_y))
}

fn quadrant(robots: List(Robot)) {
  let assert Ok(x_split) = int.divide(grid_x, 2)
  let assert Ok(y_split) = int.divide(grid_y, 2)
  let counts = QuadrantCounts(0, 0, 0, 0)

  let finished_counts =
    robots
    |> list.fold(counts, fn(counts, robot) {
      let #(x, y) = robot.position
      case x {
        _ if x < x_split ->
          case y {
            _ if y < y_split -> QuadrantCounts(..counts, q1: counts.q1 + 1)
            _ if y > y_split -> QuadrantCounts(..counts, q3: counts.q3 + 1)
            _ -> counts
          }
        _ if x > x_split ->
          case y {
            _ if y < y_split -> QuadrantCounts(..counts, q2: counts.q2 + 1)
            _ if y > y_split -> QuadrantCounts(..counts, q4: counts.q4 + 1)
            _ -> counts
          }
        _ -> counts
      }
    })
}

fn part1(robots: List(Robot)) {
  let finished_counts =
    list.range(1, 100)
    |> list.fold(from: robots, with: fn(robots, _) {
      robots
      |> list.map(move_robot)
    })
    |> quadrant

  finished_counts.q1
  * finished_counts.q2
  * finished_counts.q3
  * finished_counts.q4
  // |> robots_to_grid
  // |> io.print
  // io.println("")
  // io.println("")
}

fn part2(robots: List(Robot)) {
  list.range(1, 10_000)
  |> list.fold(from: robots, with: fn(robots, i) {
    let moved_robots =
      robots
      |> list.map(move_robot)

    let finished_counts =
      moved_robots
      |> quadrant
    let filepath = "./out/" <> int.to_string(i) <> ".pgm"

    let assert Ok(_) =
      {
        "P2\n"
        <> int.to_string(grid_x)
        <> " "
        <> int.to_string(grid_y)
        <> "\n"
        <> "1"
        <> "\n"
      }
      |> simplifile.write(to: filepath)

    let assert Ok(_) =
      moved_robots
      |> robots_to_grid
      |> simplifile.append(to: filepath)

    moved_robots
  })
  // |> robots_to_grid
  // |> io.print
  // io.println("")
  // io.println("")
}

pub fn main() {
  let filepath = "../../data/day14_test.txt"
  let assert Ok(input) = simplifile.read(from: filepath)
  let robots = parse_robots(input)
  // robots |> io.debug
  part1(robots)
  part2(robots)
  //|> io.debug
}
