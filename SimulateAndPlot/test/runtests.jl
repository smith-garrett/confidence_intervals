using Test
using SimulateAndPlot

@testset "generate_data produces output with correct dimensions" begin
    for (n_exp, n_samp) in zip([0, 1, 2], [0, 1, 10])
        exp_config = ExperimentConfig(n_exp, n_samp)
        @test all(size(generate_data(exp_config)) .== [n_exp, n_samp])
    end
end
