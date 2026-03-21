using HTTP
using JSON3
using Oxygen
using SimulateAndPlot

@post "/" function (request::HTTP.Request)
    exp_info = json(request, ExperimentConfig)
    means, ci_half_widths = calculate_mean_and_ci_half_width(generate_data(exp_info))
    return number_that_dont_include_zero(means, ci_half_widths)
end

@get "/healthz" function ()
    HTTP.Response(200)
end

serve()

