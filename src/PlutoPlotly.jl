module PlutoPlotly

using Reexport
@reexport using PlotlyBase

using HypertextLiteral
using PackageExtensionCompat
using AbstractPlutoDingetjes
using Dates
using BaseDirs
using TOML
using Markdown
using Downloads: download

export PlutoPlot, get_plotly_version, change_plotly_version,
check_plotly_version, force_pluto_mathjax_local, htl_js, add_plotly_listener!,
add_class!, remove_class!, add_js_listener!
export plot, push_script!, prepend_cell_selector

include("local_plotly_library.jl")

include("main_struct.jl")
include("basics.jl")
include("mathjax.jl")
include("preprocess.jl")
include("js_helpers.jl")
include("show.jl")

function __init__()
	# if !is_inside_pluto()
	# 	@warn "You loaded this package outside of Pluto, this is not the intended behavior and you should use either PlotlyBase or PlotlyJS directly.\nNOTE: If you receive this warning during pre-compilation or sysimage creation, you can ignore this warning."
	# end
    @require_extensions
end

end