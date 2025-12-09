import gleam/int
import gleam/list
import gleam/pair
import gleam/string

// const test_data = "R1000"

// const test_data = "L68
// L30
// R48
// L5
// R60
// L55
// L1
// L99
// R14
// L82"

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> list.scan(from: 50, with: int.add)
  |> list.count(fn(x) { x % 100 == 0 })
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.fold(from: #(50, 0), with: stolen_from_reddit)
  |> pair.second
}

pub fn stolen_from_reddit(prev_state: #(Int, Int), line) -> #(Int, Int) {
  let #(prev_digit, zero_count) = prev_state
  let assert #(d, Ok(raw_digit)) = case line {
    "L" <> raw_digit -> #(0, int.parse(raw_digit))
    "R" <> raw_digit -> #(1, int.parse(raw_digit))
    _ -> panic
  }
  let clicks = raw_digit * { 1 - 2 * d }
  let assert Ok(a) = int.floor_divide(prev_digit - d, 100)
  let assert Ok(b) = int.floor_divide(prev_digit + clicks - d, 100)
  #(prev_digit + clicks, zero_count + int.absolute_value(a - b))
}

// pub fn pt_2(input: String) {
//   // let input = test_data
//   input
//   |> string.split("\n")
//   |> list.map(parse_line)
//   |> list.fold(from: #(50, 0), with: mod_add_track_passing_zero)
//   |> pair.second
// }

pub fn mod_add_track_passing_zero(
  prev_state: #(Int, Int),
  clicks: Int,
) -> #(Int, Int) {
  let #(prev_digit, zero_count) = prev_state
  let assert Ok(click_minus_full_turns) = int.remainder(clicks, 100)
  let raw_add = prev_digit + click_minus_full_turns

  let assert Ok(new_digit) = int.modulo(raw_add, 100)
  let full_turns = int.absolute_value(clicks / 100)
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
