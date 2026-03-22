import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

type Model {
  Model(image: ImageState)
}

type ImageState {
  ImageAvailable(svg: String)
  NoImageAvailable
}

type Msg {
  UserSubmittedExperimentConfig
  ApiReturnedImage(Result(String, rsvp.Error))
}

fn init(_args: a) -> #(Model, Effect(Msg)) {
  let model = Model(NoImageAvailable)
  #(model, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSubmittedExperimentConfig -> #(
      Model(image: NoImageAvailable),
      get_figure(),
    )
    ApiReturnedImage(Ok(img)) -> {
      io.println("Got image, length: " <> int.to_string(string.length(img)))
      #(Model(image: ImageAvailable(img)), effect.none())
    }
    ApiReturnedImage(Error(err)) -> {
      echo err
      #(model, effect.none())
    }
  }
}

fn get_figure() -> Effect(Msg) {
  let url = "http://127.0.0.1:8080/"
  let handler =
    rsvp.expect_ok_response(fn(res) {
      case res {
        Ok(response) -> ApiReturnedImage(Ok(response.body))
        Error(err) -> ApiReturnedImage(Error(err))
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
    case model.image {
      ImageAvailable(svg) -> element.unsafe_raw_html("", "div", [], svg)
      NoImageAvailable -> html.p([], [html.text("Waiting...")])
    },
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
