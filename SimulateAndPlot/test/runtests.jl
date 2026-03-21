using Test
using SimulateAndPlot

@testset "generate_data produces output with correct dimensions" begin
    for (n_exp, n_samp) in zip([0, 1, 2], [0, 1, 10])
        exp_config = ExperimentConfig(n_exp, n_samp)
        @test all(size(generate_data(exp_config)) .== [n_exp, n_samp])
    end
end

@testset "calculate_mean_and_ci_half_width generates correct half-width" begin
    n_exp = 1
    for n_samp in [100, 1000]
        exp_config = ExperimentConfig(n_exp, n_samp)
        data = generate_data(exp_config)
        avg, ci_half_width = calculate_mean_and_ci_half_width(data)
        @test ci_half_width[1] ≈ (2 / sqrt(n_samp)) rtol = 0.2
    end

end

@testset "number_that_dont_include_zero correctly counts significant differences" begin
    means = [[0], [1], [2], [-1, 0.5], [-1, 0.5]]
    errors = [[1], [1], [1], [0.5, 1], [1, 0.25]]
    cts = [0, 0, 1, 1, 1]
    for (avg, err, ct) in zip(means, errors, cts)
        @test number_that_dont_include_zero(avg, err) == ct
    end
end
