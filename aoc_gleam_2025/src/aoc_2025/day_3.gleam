import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_to_int)
  |> list.map(fn(battery_bank) {
    let first = battery_max(battery_bank, True, MaxState(0, [0]))
    let second = battery_max(first.remaining_batteries, False, MaxState(0, [0]))
    let assert Ok(comb) =
      int.parse(int.to_string(first.val) <> int.to_string(second.val))
    comb
  })
  |> int.sum
}

pub type MaxState {
  MaxState(val: Int, remaining_batteries: List(Int))
}

pub fn battery_max(
  battery_bank: List(Int),
  is_first: Bool,
  max: MaxState,
) -> MaxState {
  case battery_bank, is_first {
    // the first value can't be last in the bank
    [_], True -> max
    [x, ..rest], _ ->
      case x > max.val {
        True ->
          battery_max(
            rest,
            is_first,
            MaxState(val: x, remaining_batteries: rest),
          )
        False -> battery_max(rest, is_first, max)
      }
    _, _ -> max
  }
}

pub fn parse_to_int(line: String) -> List(Int) {
  let assert Ok(parsed_line) =
    line
    |> string.to_graphemes
    |> list.try_map(int.parse)
  parsed_line
}

// add to list if 12 - length(list) == remaining -> max
pub fn pt_2(input: String) {
  // let assert Ok(values) =
    input
    |> string.split("\n")
    |> list.map(parse_to_int)
    |> list.map(fn(battery_bank) { battery_max_2_outer(battery_bank, 12, 0) })
    |> int.sum
    // |> list.try_map(int.parse)
  // int.sum(values)
}

pub fn battery_max_2_outer(
  battery_bank: List(Int),
  size: Int,
  prev_max: Int,
) -> Int {
  case size > 0 {
    True -> {
      let max = battery_max_2(battery_bank, size, MaxState(0, [0]))
      // let prev_max = prev_max <> int.to_string(max.val)
      let assert Ok(scale) = int.power(10, int.to_float(size))
      battery_max_2_outer(max.remaining_batteries, size - 1, prev_max + max.val * float.truncate(scale))
    }
    False -> prev_max
  }
}

pub fn battery_max_2(
  battery_bank: List(Int),
  size: Int,
  max: MaxState,
) -> MaxState {
  use <- bool.guard(when: size-1 == list.length(battery_bank), return: max)
  case battery_bank {
    [x, ..rest] ->
      case x > max.val {
        True ->
          battery_max_2(rest, size, MaxState(val: x, remaining_batteries: rest))
        False -> battery_max_2(rest, size, max)
      }
    _ -> max
  }
}
