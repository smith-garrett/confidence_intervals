import front_end/plot
import front_end/simulate
import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

type Model {
  Model(model_state: State)
}

type State {
  NoFigureLoadedYet
  FigureAvailable
}

type Msg {
  UserSubmittedExperimentConfig
}

fn init(_args: a) -> #(Model, Effect(Msg)) {
  let model = Model(model_state: NoFigureLoadedYet)
  #(model, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSubmittedExperimentConfig -> #(
      Model(model_state: FigureAvailable),
      effectful_plot("main", 100, 100),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.script([attribute.src("https://cdn.plot.ly/plotly-3.4.0.min.js")], ""),
    html.div([], [
      html.button([event.on_click(UserSubmittedExperimentConfig)], [
        html.text("Run simulation"),
      ]),
      html.p([], [html.text("Figure")]),
    ]),
    html.div([attribute.id("chart-main")], []),
    case model.model_state {
      NoFigureLoadedYet ->
        html.p([], [html.text("Please click to run a simulation")])
      FigureAvailable -> html.p([], [])
    },
  ])
}

fn effectful_plot(name: String, n_exps: Int, n_samples: Int) -> Effect(Msg) {
  let x_values = int.range(n_exps, 0, [], fn(acc, i) { list.prepend(acc, i) })
  let means_and_cis =
    simulate.calculate_means_and_ci_half_widths(
      simulate.generate_data(simulate.ExperimentConfig(
        n_experiments: n_exps,
        n_samples_per_experiment: n_samples,
      )),
    )
  effect.from(fn(_dispatch) {
    plot.plotly_plot(
      "chart-" <> name,
      x_values,
      means_and_cis.means,
      means_and_cis.half_widths,
    )
  })
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
