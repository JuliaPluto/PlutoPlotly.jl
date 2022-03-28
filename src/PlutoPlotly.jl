module PlutoPlotly

using Reexport
@reexport using PlotlyBase

export PlutoPlot, get_plotly_version, change_plotly_version, check_plotly_version, force_pluto_mathjax_local, htl_js
include("../notebooks/wrapper.jl")

end