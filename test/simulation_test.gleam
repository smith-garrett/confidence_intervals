import front_end/simulate
import gleam/float
import gleam/int
import gleam/list

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

/// The Irwin-Hall approximation to the normal distribution should always fall within [-6, 6]
pub fn randn_test() {
  let std_normal_variates =
    int.range(0, 1000, [], fn(lst, _i) { list.append(lst, [simulate.randn()]) })
  assert list.all(std_normal_variates, fn(x) { -6.0 <. x && x <. 6.0 })
  let mean =
    float.sum(std_normal_variates)
    /. int.to_float(list.length(std_normal_variates))
  float.loosely_equals(mean, 0.0, 0.1)
}

pub fn generate_data_test() {
  let exp_config = simulate.ExperimentConfig(5, 5)
  assert list.length(simulate.generate_data(exp_config)) == 5
}

pub fn calculate_means_and_ci_half_widths_test() {
  let data = [[-1.0, 0.0, 1.0]]
  let res = simulate.calculate_means_and_ci_half_widths(data)
  assert res.means == [0.0]
  assert res.half_widths == [1.96]
}
