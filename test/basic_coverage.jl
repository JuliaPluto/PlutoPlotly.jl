using Test
using PlutoPlotly
using PlutoPlotly: _preprocess, SKIP_FLOAT32, skip_float32
using PlutoPlotly.PlotlyBase: ColorScheme, Colors, Cycler

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

@test default_plotly_template() === "plotly"
@test default_plotly_template("none") === "none"
