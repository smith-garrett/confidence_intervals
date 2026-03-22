import gleam/json
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

type Model {
  Model(model_state: State)
}

type State {
  NoFigureLoadedYet
  FigureAvailable(svg: String)
  NoFigureAvailable
  FigureError
}

type Msg {
  UserSubmittedExperimentConfig
  ApiReturnedFigure(Result(String, rsvp.Error))
}

fn init(_args: a) -> #(Model, Effect(Msg)) {
  let model = Model(NoFigureLoadedYet)
  #(model, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSubmittedExperimentConfig -> #(
      Model(model_state: NoFigureAvailable),
      get_figure(),
    )
    ApiReturnedFigure(Ok(img)) -> {
      #(Model(model_state: FigureAvailable(img)), effect.none())
    }
    ApiReturnedFigure(Error(err)) -> {
      #(Model(FigureError), effect.none())
    }
  }
}

fn get_figure() -> Effect(Msg) {
  let url = "http://127.0.0.1:8080/"
  let handler =
    rsvp.expect_ok_response(fn(res) {
      case res {
        Ok(response) -> ApiReturnedFigure(Ok(response.body))
        Error(err) -> ApiReturnedFigure(Error(err))
      }
    })
  let payload =
    json.object([
      #("n_experiments", json.int(100)),
      #("n_samples_per_experiment", json.int(10)),
    ])
  rsvp.post(url, payload, handler)
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.div([], [
      html.button([event.on_click(UserSubmittedExperimentConfig)], [
        html.text("Run simulation"),
      ]),
      html.p([], [html.text("Figure")]),
    ]),
    case model.model_state {
      NoFigureLoadedYet ->
        html.p([], [html.text("Please click to run a simulation")])
      FigureAvailable(svg) -> element.unsafe_raw_html("", "div", [], svg)
      NoFigureAvailable -> html.p([], [html.text("Waiting...")])
      FigureError -> html.p([], [html.text("Figure could not be loaded.")])
    },
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
