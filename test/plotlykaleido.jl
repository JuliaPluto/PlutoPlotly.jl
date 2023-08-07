using PlutoPlotly
using PlotlyKaleido
using Test

mktempdir() do dir
    cd() do 
        p = plot(rand(10,4))
        @test_nowarn savefig(p, "test_savefig.png")
        @test isfile("test_savefig.png")
    end
end