import front_end/plot
import front_end/simulate
import gleam/int
import gleam/list
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

type Model {
  Model(model_state: State, n_exp: Int, n_samples: Int)
}

type State {
  NoFigureLoadedYet
  FigureAvailable
}

type Msg {
  UserEnteredNumExperiments(String)
  UserEnterdNumSamples(String)
  UserSubmittedExperimentConfig
}

fn init(_args: a) -> #(Model, Effect(Msg)) {
  let model = Model(model_state: NoFigureLoadedYet, n_exp: 100, n_samples: 100)
  #(model, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserEnteredNumExperiments(n_exp) -> {
      let n = result.unwrap(int.parse(n_exp), model.n_samples)
      #(Model(..model, n_exp: n), effect.none())
    }
    UserEnterdNumSamples(n_samples) -> {
      let n = result.unwrap(int.parse(n_samples), model.n_samples)
      #(Model(..model, n_samples: n), effect.none())
    }
    UserSubmittedExperimentConfig -> #(
      Model(..model, model_state: FigureAvailable),
      effectful_plot("main", model.n_exp, model.n_samples),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.html([], [
    html.head([], [
      html.style(
        [],
        "body{margin:40px auto;
max-width:650px;
line-height:1.6;
font-size:18px;
color:#444;
padding:0 10px}
h1,h2,h3{line-height:1.2}
aside{display:inline;
float:right;
position:relative;
width:20vw;
margin-right:-22vw;
font-size:14px}",
      ),
      html.title([], "WORK IN PROGRESS: Confidence intervals"),
      html.script(
        [attribute.src("https://cdn.plot.ly/plotly-3.4.0.min.js")],
        "",
      ),
    ]),
    html.body([], [
      html.a([attribute.href("https://smith-garrett.github.io/posts/")], [
        html.text("< Back to posts"),
      ]),
      html.h1([], [html.text("Confidence intervals")]),
      html.div([], [
        html.p([], [
          html.text(
            "Confidence intervals are unintuitive things. The name \"confidence intervals\" is misleading, because they don't really have anything to do with confidence at all. Misinterpretations are common: Wikipedia has a ",
          ),
          html.a(
            [
              attribute.href(
                "https://en.wikipedia.org/wiki/Confidence_interval#Common_misunderstandings",
              ),
            ],
            [html.text("whole subsection")],
          ),
          html.text(
            " on its page on confidence intervals dedicated to common misinterpretations. Even professional researchers often endorse incorrect interpretations, ",
          ),
          html.a(
            [
              attribute.href(
                "https://link.springer.com/content/pdf/10.3758/s13423-013-0572-3.pdf",
              ),
            ],
            [html.text("in one study")],
          ),
          html.text(
            " performing only slightly better than students without training in statistics.",
          ),
        ]),
        html.p([], [
          html.text(
            "But while it's easy to get confidence intervals wrong, the concept is not actually that complicated. All a confidence interval is is this: If we gather data and calculate the mean and confidence interval in the same way many times, the calculated confidence intervals should contain the true value of the mean 95% of the time. But for a given experiment, we can never know if the current confidence interval actually contains the true value.",
          ),
        ]),
        html.p([], [
          html.text(
            "In words, the definition still feels abstract, but it's easy to visualize. The tool below allows us to simulate repeated experiments under the exact same conditions. You can enter the number of experiments to run and the number of data points to sample per experiment.",
          ),
        ]),
        html.p([], [
          html.text(
            "When you click the button, random samples from a standard normal distribution are drawn (mean zero and standard deviation one). The average of the data points is calculated, as well as the 95% confidence interval of the mean. This is repeated for each experiment. The plot shows the mean for each experiment and the limits of the 95% confidence interval. Play around with the parameters of the simulation.",
          ),
          html.aside([], [
            html.text(
              "Note that these confidence intervals are calculated using the ",
            ),
            html.a(
              [
                attribute.href(
                  "https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals",
                ),
              ],
              [html.text("asymtotic approximatation, ")],
            ),
            html.text(
              "which is only valid for large sample sizes. For per-experiment sample sizes less than about 30, the confidence intervals get too small, and less than 95% of them contain zero.",
            ),
          ]),
        ]),
        html.hr([]),
        html.form([], [
          html.p([], [
            html.label([attribute.for("n-exp-input")], [
              html.text("Number of experiments to run: "),
            ]),
            html.input([
              attribute.id("n-exp-input"),
              attribute.type_("number"),
              attribute.step("1"),
              attribute.value(int.to_string(model.n_exp)),
              event.on_input(UserEnteredNumExperiments),
            ]),
          ]),
          html.p([], [
            html.label([attribute.for("n-samples-input")], [
              html.text("Number of samples per experiment: "),
            ]),
            html.input([
              attribute.id("n-samples-input"),
              attribute.type_("number"),
              attribute.step("1"),
              attribute.value(int.to_string(model.n_samples)),
              event.on_input(UserEnterdNumSamples),
            ]),
          ]),
          html.p([], [
            html.button(
              [
                attribute.type_("button"),
                event.on_click(UserSubmittedExperimentConfig),
              ],
              [
                html.text("Run simulation"),
              ],
            ),
          ]),
        ]),
        html.div([attribute.id("chart-main")], []),
        case model.model_state {
          NoFigureLoadedYet ->
            html.p([], [html.text("Please click to run experiments.")])
          FigureAvailable ->
            html.p([], [
              html.text(
                "Experiments where the 95% confidence interval (CI) does not contain the true value (zero) are plotted with red Xs; all other experiments are plotted with black circles.",
              ),
            ])
        },
        html.hr([]),
        html.p([], [
          html.text(
            "Notice that the confidence interval calculated from a single experiment is not very informative. We can't know if it is one of the 95% that contains the true value or if we got unlucky and it completely misses the true value. All we can really say is that if our confidence interval is narrow, ",
          ),
          html.a(
            [
              attribute.href(
                "https://vasishth.github.io/Freq_CogSci/the-confidence-interval-and-what-its-good-for.html",
              ),
            ],
            [
              html.text(
                "then our estimate of the mean is probably pretty precise. ",
              ),
            ],
          ),
          html.aside([], [
            html.text(
              "Notice how the confidence intervals in the plot get narrower if you increase the number of samples per experiment.",
            ),
          ]),
        ]),
        html.p([], [
          html.text(
            "The nice thing about simulations is that we know exactly what the true values are. We know the true value of the mean, because we chose it to be zero; variability around that value is due to the randomness of sampling. With this choice, we can easily check to make sure that our confidence intervals behave as expected. For any real experiment, we can never perform such a check because we generally don't have access to the true data-generating process and therefore can't know what the true value is.",
          ),
        ]),
        html.p([], [
          html.text(
            "Another crucial take-away: The data are random in each experiment, which makes the means calculated from each data set a random themselves. The true value of the mean, on the other hand, is assumed to be a single, unchanging, fixed value. This is a central assumption of ",
          ),
          html.a(
            [
              attribute.href(
                "https://en.wikipedia.org/wiki/Frequentist_inference",
              ),
            ],
            [html.text("frequentist statistics.")],
          ),
          html.text(
            " We can't know the true value, but if we do our stats carefully, then we can hope that our estimates from variable data will be reasonably close.",
          ),
        ]),
        html.p([], [
          html.text(
            "So there we go. Confidence intervals just tell us something about our sampling procedure: if it is set up well, then the 95% confidence interval around the mean should contain the true value in 95% of repeated experiments. That tells us very little about one particular experiment, though. If we want to draw a conclusion about a single experiment to the effect of, \"I am 95% certain that the mean of this data set lies in the interval [a, b] given the data and my assumptions,\" then we will need to switch to a ",
          ),
          html.a([attribute.href("https://bruno.nicenboim.me/bayescogsci/")], [
            html.text("Bayesian approach."),
          ]),
          html.text(
            " Bayesian statistics comes with its own challenges, but in certain ways, it's more intuitive, in my view. But that will have to wait for another post. 😉",
          ),
        ]),
      ]),
    ]),
  ])
}

fn effectful_plot(name: String, n_exps: Int, n_samples: Int) -> Effect(Msg) {
  let x_values = int.range(n_exps, 0, [], fn(acc, i) { list.prepend(acc, i) })

  let exp_config =
    simulate.ExperimentConfig(
      n_experiments: n_exps,
      n_samples_per_experiment: n_samples,
    )

  let means_and_cis =
    simulate.calculate_means_and_ci_half_widths(
      exp_config,
      simulate.generate_data(exp_config),
    )

  let colors = plot.get_colors(means_and_cis)
  let n_sig = list.count(colors, fn(x) { x == "red" })

  effect.from(fn(_dispatch) {
    plot.plotly_plot(
      "chart-" <> name,
      x_values,
      means_and_cis.means,
      means_and_cis.half_widths,
      colors,
      plot.get_shapes(means_and_cis),
      n_sig |> int.to_string <> " CIs do not include zero",
    )
  })
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
