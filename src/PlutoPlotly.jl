module PlutoPlotly

using PlotlyBase

using HypertextLiteral
using AbstractPlutoDingetjes
using Dates
using Scratch
using TOML
using Colors
using ColorSchemes
using LaTeXStrings
using Markdown
using Downloads: download
using Artifacts
using ScopedValues
using PrecompileTools
# This is similar to `@reexport` but does not exports undefined names and can
# also avoid exporting the module name
function re_export(m::Module; skip_modname = false)
    mod_name = nameof(m)
    nms = names(m)
    exprts = filter(nms) do n
        isdefined(m, n) && (!skip_modname || n != mod_name)
    end
    eval(:(using .$mod_name))
    eval(:(export $(exprts...)))
end

re_export(PlotlyBase; skip_modname = false)
export PlutoPlot, get_plotly_version, change_plotly_version,
force_pluto_mathjax_local, htl_js, add_plotly_listener!,
add_class!, remove_class!, add_js_listener!, default_plotly_template,
get_image_options, change_image_options!, plutoplotly_paste_receiver
export plot, push_script!, prepend_cell_selector
export make_subplots
export enable_plutoplotly_offline
# From utilities.jl
export sample_colorscheme, discrete_colorscale


include("local_plotly_library.jl")

include("basics.jl")
include("script_contents/clipboard.jl")
include("script_contents/resizer.jl")
include("main_struct.jl")
include("paste_receiver.jl")
include("mathjax.jl")
include("preprocess.jl")
include("js_helpers.jl")
include("show.jl")
# Forward methods of PlotlyBase to support PlutoPlot objects
include("plotlybase_forward.jl")
include("utilities.jl")

# function __init__()
	# if !is_inside_pluto()
	# 	@warn "You loaded this package outside of Pluto, this is not the intended behavior and you should use either PlotlyBase or PlotlyJS directly.\nNOTE: If you receive this warning during pre-compilation or sysimage creation, you can ignore this warning."
	# end
# end

@compile_workload begin
    data = [
        scatter(;y = rand(10)),
        scattergeo(;lat = rand(10), lon = rand(10)),
        heatmap(;z = rand(10,10)),
        surface(;z = rand(10,10))
    ]
    layout = Layout(;title = "lol")
    p = plot(data, layout)
    _show(p)
    plot(rand(10,4)) |> _show
end

end