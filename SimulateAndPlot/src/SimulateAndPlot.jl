module SimulateAndPlot

using CairoMakie
using Distributions
using Statistics

struct ExperimentConfig
    n_experiments::Int
    n_samples_per_experiment::Int
end


function generate_data(exp_info::ExperimentConfig)
    rand(Normal(), (exp_info.n_experiments, exp_info.n_samples_per_experiment))
end

function calculate_mean_and_ci_half_width(data)
    means = mean(data; dims=2)
    vars = var(data; dims=2)
    std_error_of_mean = sqrt.(vars ./ size(data)[2])
    return vec(means), 1.96 .* vec(std_error_of_mean)
end

function indices_where_zero_is_excluded(means, ci_half_widths)
    (means .- ci_half_widths) .> 0 .|| (means .+ ci_half_widths) .< 0
end

function number_that_dont_include_zero(means, ci_half_widths)
    count(indices_where_zero_is_excluded(means, ci_half_widths))
end

function fig_to_svg(fig)
    buf = IOBuffer()
    CairoMakie.save(buf, fig)
    return String(take!(buf))
end

function make_plot(means, ci_half_widths)
    n_values = length(means)
    color_to_use = fill(:green, n_values)
    color_to_use[indices_where_zero_is_excluded(means, ci_half_widths)] .= :red

    CairoMakie.activate!(type="svg")
    fig = Figure()
    ax = Axis(fig[1, 1])
    errorbars!(ax, 1:n_values, means, ci_half_widths; color=color_to_use)
    scatter!(ax, 1:n_values, means; color=color_to_use)
    return fig_to_svg(fig)
end

export ExperimentConfig
export generate_data, calculate_mean_and_ci_half_width, number_that_dont_include_zero
export make_plot

end
