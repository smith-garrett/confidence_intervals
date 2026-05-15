import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam_community/maths

pub type ExperimentConfig {
  ExperimentConfig(n_experiments: Int, n_samples_per_experiment: Int)
}

pub type MeansAndCIHalfWidths {
  MeansAndCIHalfWidths(means: List(Float), half_widths: List(Float))
}

/// Box-Muller method
pub fn randn() -> Float {
  let u = float.random()
  let lnu = result.unwrap(maths.natural_logarithm(u), 0.0)
  let v = float.random()
  let mult = result.unwrap(float.square_root(-2.0 *. lnu), 0.0)
  mult *. maths.cos(2.0 *. maths.pi() *. v)
}

pub fn get_exp_data(n_samples: Int, data: List(Float)) -> List(Float) {
  case n_samples > 0, data {
    True, [] | True, [_, ..] ->
      get_exp_data(n_samples - 1, list.prepend(data, randn()))
    False, _ -> data
  }
}

pub fn get_many_experiments(
  n_samples: Int,
  n_experiments: Int,
  data_list: List(List(Float)),
) -> List(List(Float)) {
  let init_list: List(Float) = []

  case n_experiments > 0, data_list {
    True, [] | True, [_, ..] ->
      get_many_experiments(
        n_samples,
        n_experiments - 1,
        list.append(data_list, [get_exp_data(n_samples, init_list)]),
      )
    False, _ -> data_list
  }
}

pub fn generate_data(exp_config: ExperimentConfig) -> List(List(Float)) {
  let init_list: List(List(Float)) = []
  get_many_experiments(
    exp_config.n_samples_per_experiment,
    exp_config.n_experiments,
    init_list,
  )
}

pub fn calculate_means_and_ci_half_widths(
  exp_config: ExperimentConfig,
  data: List(List(Float)),
) -> MeansAndCIHalfWidths {
  let means = data |> list.map(maths.mean) |> result.values
  let vars = data |> list.map(maths.variance(_, 1)) |> result.values
  // Using a normal approximation, gets wonky for small sample sizes (~< 30)!
  let ci_half_widths =
    list.map(vars, fn(x) {
      let std_error =
        float.square_root(
          x /. int.to_float(exp_config.n_samples_per_experiment),
        )
      result.unwrap(std_error, 0.0) *. 1.96
    })
  MeansAndCIHalfWidths(means, ci_half_widths)
}
