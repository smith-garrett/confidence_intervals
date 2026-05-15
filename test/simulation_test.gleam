import front_end/simulate
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam_community/maths

pub fn get_exp_data_test() {
  let empty_list: List(Float) = []
  assert list.length(simulate.get_exp_data(5, empty_list)) == 5
  assert list.is_empty(simulate.get_exp_data(0, empty_list))
}

pub fn get_many_experiments_test() {
  let empty_exps: List(List(Float)) = []
  assert list.is_empty(simulate.get_many_experiments(5, 0, empty_exps))
  let res = simulate.get_many_experiments(5, 3, empty_exps)
  assert list.length(res) == 3
  assert res |> list.map(list.length) |> list.all(fn(x) { x == 5 })
}

pub fn randn_test() {
  let samples =
    int.range(0, 10_000, [], fn(lst, _i) { list.prepend(lst, simulate.randn()) })

  assert float.loosely_equals(
    result.unwrap(maths.mean(samples), 1.0),
    0.0,
    0.01,
  )

  assert float.loosely_equals(
    result.unwrap(maths.variance(samples, 1), 0.0),
    1.0,
    0.1,
  )
}

pub fn generate_data_test() {
  let exp_config = simulate.ExperimentConfig(5, 5)
  assert list.length(simulate.generate_data(exp_config)) == 5
}

pub fn calculate_means_and_ci_half_widths_test() {
  let exp_config =
    simulate.ExperimentConfig(n_experiments: 1, n_samples_per_experiment: 3)
  let data = [[-1.0, 0.0, 1.0]]
  let res = simulate.calculate_means_and_ci_half_widths(exp_config, data)
  assert res.means == [0.0]
  assert res.half_widths == [1.96 /. result.unwrap(float.square_root(3.0), 1.0)]
}
