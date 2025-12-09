import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> list.scan(from: 50, with: mod_add)
  |> list.filter(fn(x) { x == 0 })
  |> list.length
}

pub fn pt_2(input: String) {
  // let input = test_data
  let #(_, zero_passes) =
    input
    |> string.split("\n")
    |> list.map(parse_line)
    |> list.fold(from: #(50, 0), with: mod_add_track_passing_zero)
  zero_passes
}

pub fn mod_add(prev_digit: Int, clicks: Int) -> Int {
  let assert Ok(new_digit) = int.modulo(prev_digit + clicks, 100)
  new_digit
}

pub fn mod_add_track_passing_zero(
  prev_state: #(Int, Int),
  clicks: Int,
) -> #(Int, Int) {
  // echo prev_state
  // echo clicks
  let #(prev_digit, zero_count) = prev_state
  let raw_add = prev_digit + clicks
  let assert Ok(new_digit) = int.modulo(raw_add, 100)
  // let assert Ok(full_turns_raw) = int.floor_divide(clicks, 100)
  // let full_turns = int.absolute_value(full_turns_raw)
  let full_turns = int.absolute_value(clicks / 100)
  echo #(clicks, full_turns)
  case { new_digit != raw_add || new_digit == 0 } && prev_digit != 0 {
    True -> #(new_digit, zero_count + full_turns + 1)
    False -> #(new_digit, zero_count + full_turns)
  }
}

pub fn parse_line(line: String) -> Int {
  case line {
    "L" <> raw_digit -> {
      let assert Ok(digit) = int.parse(raw_digit)
      int.negate(digit)
    }
    "R" <> raw_digit -> {
      let assert Ok(digit) = int.parse(raw_digit)
      digit
    }
    _ -> panic
  }
}
