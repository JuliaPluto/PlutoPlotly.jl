using Test
using PlutoPlotly
using PlutoPlotly: _preprocess, FORCE_FLOAT32, ARTIFACT_VERSION, PLOTLY_VERSION, _process_with_names
using PlutoPlotly.PlotlyBase: ColorScheme, Colors, Cycler, templates
using ScopedValues

p = plot(rand(Int, 4));
_p = p |> _process_with_names
@test first(_p[:data])[:y] isa Vector{Float32}
with(FORCE_FLOAT32 => false) do 
    _p = p |> _process_with_names
    @test first(_p[:data])[:y] isa Vector{Int}
end

@test force_pluto_mathjax_local() === false
try
    force_pluto_mathjax_local(true)
    @test force_pluto_mathjax_local() === true
finally
    force_pluto_mathjax_local(false)
end

@test ColorScheme([Colors.RGB(0.0, 0.0, 0.0), Colors.RGB(1.0, 1.0, 1.0)],
"custom", "twotone, black and white") |> _process_with_names == [(0.0, "rgb(0,0,0)"), (1.0, "rgb(255,255,255)")]
@test _preprocess(SubString("asda",1:3)) === "asd"
@test _preprocess(:lol) === "lol"
@test _process_with_names(true) === true
@test _preprocess(Cycler((1,2))) == [1,2]
@test _process_with_names(1) === 1.0f0 # By default process converts to Float32
@test _preprocess(L"3+2") === raw"$3+2$"

# Check that plotly is the default
@test default_plotly_template() == templates[templates.default]
try
    @test default_plotly_template(:none) == Template()
    @test default_plotly_template("seaborn") == templates[:seaborn]
    @test_logs (:info, "The default plotly template is seaborn") default_plotly_template(;find_matching = true)
finally
    default_plotly_template(templates[templates.default]) 
end
let p = plot(rand(4))
    @test get_image_options(p) == Dict{Symbol,Any}()
    change_image_options!(p; height = 400)
    @test get_image_options(p) == Dict{Symbol,Any}(:height => 400)
    @test_throws "invalid keyword arguments" change_image_options!(p; heights = 400)
end

@test plutoplotly_paste_receiver() isa PlutoPlotly.HypertextLiteral.Result

@test get_plotly_version() === ARTIFACT_VERSION
try
    @test change_plotly_version("2.30") === VersionNumber("2.30.0")
    @test get_plotly_version() === VersionNumber("2.30.0")
    @test VersionNumber("2.33.0") === with(PLOTLY_VERSION => "2.33") do 
        get_plotly_version()
    end 
finally
# We put back the default version to be the ARTIFACT one. This is to avoid errors while repeating multiple times tests locally
    change_plotly_version(ARTIFACT_VERSION)
end