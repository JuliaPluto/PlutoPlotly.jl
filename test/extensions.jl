using PlutoPlotly
using Test

## PlotlyKaleido Extension ##
using PlotlyKaleido
if Sys.islinux()
    # We only test this in linux as the library fail in CI on Mac OS and Windows
    PlotlyKaleido.start()

    mktempdir() do dir
        cd() do 
            p = plot(rand(10,4))
            @test_nowarn savefig(p, "test_savefig.png")
            @test isfile("test_savefig.png")
        end
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
