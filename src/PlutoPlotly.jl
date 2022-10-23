module PlutoPlotly

using Reexport
@reexport using PlotlyBase

export PlutoPlot, get_plotly_version, change_plotly_version, check_plotly_version, force_pluto_mathjax_local, htl_js, add_plotly_listener!, add_class!, remove_class!, add_js_listener!
export plot, push_script!, prepend_cell_selector
include("../notebooks/wrapper.jl")

function __init__()
	if !is_inside_pluto()
		@warn "You loaded this package outside of Pluto, this is not the intended behavior and you should use either PlotlyBase or PlotlyJS directly"
	end
end

end