@testitem "colorscale_utilities" begin
    using PlutoPlotly.Colors
    cs = sample_colorscheme(:viridis)
    @test length(cs) === 256
    @test cs.colors isa Vector{<:RGBA}
    @test all(c -> c.alpha == 1.0, cs.colors)

    css = sample_colorscheme(cs, 10; alpha = 0.5)
    @test length(css) === 10
    @test all(c -> c.alpha == 0.5, css.colors)

    @test_throws "must be a valid key" sample_colorscheme(:parula)

    # discrete_colorscale
    dcs = discrete_colorscale(cs, 10)
    @test length(dcs) === 10 * 2
    @test dcs isa Vector{Tuple{Float64, String}}
end