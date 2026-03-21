using Distributions
using Statistics
using HTTP
using JSON3
using Oxygen

struct ExperimentInfo
    n_experiments::Int
    n_samples_per_experiment::Int
end


function generate_data(exp_info::ExperimentInfo)
    rand(Normal(), (exp_info.n_experiments, exp_info.n_samples_per_experiment))
end

function calculate_mean_and_ci_half_width(data)
    means = mean(data; dims=2)
    vars = var(data; dims=2)
    std_error_of_mean = sqrt.(vars) ./ size(data)[2]
    return vec(means), 2 .* vec(std_error_of_mean)
end

function number_that_dont_include_zero(means, ci_half_widths)
    count((means.-ci_half_widths) .> 0 .|| (means.+ci_half_widths) .< 0)
end

@post "/" function (request::HTTP.Request)
    exp_info = json(request, ExperimentInfo)
    means, ci_half_widths = calculate_mean_and_ci_half_width(generate_data(exp_info))
    return number_that_dont_include_zero(means, ci_half_widths)
end

serve()
