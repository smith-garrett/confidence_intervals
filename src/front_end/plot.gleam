import front_end/simulate
import gleam/list

@external(javascript, "./makePlot.js", "makePlot")
pub fn plotly_plot(
  id: String,
  x: List(Int),
  y: List(Float),
  err: List(Float),
  color: List(String),
  shapes: List(String),
) -> Nil

pub fn get_colors(
  means_and_cis: simulate.MeansAndCIHalfWidths,
) -> List(String) {
  list.zip(means_and_cis.means, means_and_cis.half_widths)
  |> list.map(overlaps_with_zero)
}

fn overlaps_with_zero(value: #(Float, Float)) -> String {
  let #(mean, half_width) = value
  let upper_below_zero = mean +. half_width <. 0.0
  let lower_above_zero = mean -. half_width >. 0.0
  case { upper_below_zero || lower_above_zero } {
    True -> "red"
    False -> "black"
  }
}

pub fn get_shapes(
  means_and_cis: simulate.MeansAndCIHalfWidths,
) -> List(String) {
  list.zip(means_and_cis.means, means_and_cis.half_widths)
  |> list.map(decide_shape)
}

fn decide_shape(value: #(Float, Float)) -> String {
  let #(mean, half_width) = value
  let upper_below_zero = mean +. half_width <. 0.0
  let lower_above_zero = mean -. half_width >. 0.0
  case { upper_below_zero || lower_above_zero } {
    True -> "x"
    False -> "circle"
  }
}
