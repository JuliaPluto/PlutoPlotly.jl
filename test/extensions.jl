using PlutoPlotly
using PlutoPlotly: PLOTLY_VERSION
using Test
using ScopedValues

## PlotlyKaleido Extension ##
using PlotlyKaleido
if Sys.islinux()
    # We only test this in linux as the library fail in CI on Mac OS and Windows
    PlotlyKaleido.start()

    try
        mktempdir() do dir
            cd() do 
                p = plot(rand(10,4))
                @test_logs (:info, r"with plotly version 2.34.0") savefig(p, "test_savefig.png")
                @test isfile("test_savefig.png")
                @test_logs (:info, r"with plotly version 2.33.0") with(PLOTLY_VERSION => "2.33") do
                    savefig(p, "test_changeversion.png")
                end
                @test isfile("test_changeversion.png")
            end
        end
    finally
        PlotlyKaleido.kill_kaleido()
    end
end

## Unitful Extension ##
using PlutoPlotly: _preprocess
using Unitful: °, ustrip

uv_r = range(0°, 100°; step = 1°)
@test _preprocess(uv_r) == collect(0:100)
uv_a = rand(3,5) .* °
uv_a_strip = ustrip.(uv_a)
@test _preprocess(uv_a) == _preprocess(uv_a_strip)
