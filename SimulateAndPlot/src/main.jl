using HTTP
using JSON3
using Oxygen
using SimulateAndPlot

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

function CorsMiddleware(handler)
    return function(req::HTTP.Request)
        # determine if this is a pre-flight request from the browser
        if HTTP.method(req)=="OPTIONS"
            return HTTP.Response(200, CORS_HEADERS)  
        else 
            return handler(req) # passes the request to the AuthMiddleware
        end
    end
end

@post "/" function (request::HTTP.Request)
    exp_info = json(request, ExperimentConfig)
    means, ci_half_widths = calculate_mean_and_ci_half_width(generate_data(exp_info))
    # return number_that_dont_include_zero(means, ci_half_widths),
    fig_svg = make_plot(means, ci_half_widths)
    return HTTP.Response(200, [CORS_HEADERS..., "Content-Type" => "image/svg+xml"], fig_svg)
end

@get "/healthz" function ()
    HTTP.Response(200)
end

# Warm up JIT before serving
make_plot(calculate_mean_and_ci_half_width(generate_data(ExperimentConfig(1, 1)))...)

serve(host="0.0.0.0", port=8080, middleware=[CorsMiddleware])
