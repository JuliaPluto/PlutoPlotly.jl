using SafeTestsets

@safetestset "Coverage Improvements" begin include("basic_coverage.jl") end
@safetestset "Extensions" begin include("extensions.jl") end
@safetestset "PlotlyBase API" begin include("plotlybase_api.jl") end
@safetestset "Pluto Tests" begin include("notebook_tests.jl") end