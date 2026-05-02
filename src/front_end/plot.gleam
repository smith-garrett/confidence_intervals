@external(javascript, "./makePlot.js", "makePlot")
pub fn plotly_plot(
  id: String,
  x: List(Int),
  y: List(Float),
  err: List(Float),
) -> Nil
