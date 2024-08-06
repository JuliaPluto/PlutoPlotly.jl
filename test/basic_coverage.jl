using Test
using PlutoPlotly
using PlutoPlotly: _preprocess, SKIP_FLOAT32, skip_float32, ARTIFACT_VERSION
using PlutoPlotly.PlotlyBase: ColorScheme, Colors, Cycler, templates

@test SKIP_FLOAT32[] == false
@test skip_float32() do
    SKIP_FLOAT32[]
end == true
@test SKIP_FLOAT32[] == false

@test force_pluto_mathjax_local() === false
force_pluto_mathjax_local(true)
@test force_pluto_mathjax_local() === true

@test ColorScheme([Colors.RGB(0.0, 0.0, 0.0), Colors.RGB(1.0, 1.0, 1.0)],
"custom", "twotone, black and white") |> _preprocess == [(0.0, "rgb(0,0,0)"), (1.0, "rgb(255,255,255)")]
@test _preprocess(SubString("asda",1:3)) === "asd"
@test _preprocess(:lol) === "lol"
@test _preprocess(true) === true
@test _preprocess(Cycler((1,2))) == [1,2]
@test _preprocess(1) === 1.0f0
@test _preprocess(L"3+2") === raw"$3+2$"

# Check that plotly is the default
@test default_plotly_template() == templates[templates.default]
@test default_plotly_template(:none) == Template()
@test default_plotly_template("seaborn") == templates[:seaborn]
@test_logs (:info, "The default plotly template is seaborn") default_plotly_template(;find_matching = true)

let p = plot(rand(4))
    @test get_image_options(p) == Dict{Symbol,Any}()
    change_image_options!(p; height = 400)
    @test get_image_options(p) == Dict{Symbol,Any}(:height => 400)
    @test_throws "invalid keyword arguments" change_image_options!(p; heights = 400)
end

@test plutoplotly_paste_receiver() isa PlutoPlotly.HypertextLiteral.Result

@test get_plotly_version() === ARTIFACT_VERSION
@test change_plotly_version("2.30") === VersionNumber("2.30.0")
@test get_plotly_version() === VersionNumber("2.30.0")