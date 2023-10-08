const PLOTLY_VERSION = Ref("2.26.2")

const SCType = Dictionary{String, Union{Function, Script}}

# This will contain the default contents of the script generating the plot
const _default_script_contents = SCType()


"""
	PlutoPlot(p::Plot; kwargs...)

A wrapper around `PlotlyBase.Plot` to provide optimized visualization within
Pluto notebooks exploiting `@htl` from HypertextLiteral.

# Fields
- `Plot::PlotlyBase.Plot`
- `plotly_listeners::Dict{String, Vector{HypertextLitera.JavaScript}}`
- `js_listeners::Dict{String, Vector{HypertextLitera.JavaScript}}`
- `classList::Vector{String}`
- `script_contents::ScriptContents`

Once the wrapper has been created, the underlying `Plot` object can be accessed
from the `Plot` field of the `PlutoPlot` object.

Custom listeners to [plotly
events](https://plotly.com/javascript/plotlyjs-events/) are saved inside the
`plotly_listeners` field and can be added to the `PlutoPlot` as *javascript*
functions using the [`add_plotly_listener!`](@ref) function.

Custom listeners to normal javascript events can instead be added to the
`PlutoPlot` as *javascript* functions using the [`add_js_listener!`](@ref)
function.

Multiple listeners can be associated to each event, and they are executed in the
order they are added.

A list of custom CSS classes can be added to the PlutoPlot by using the
[`add_class!`](@ref) and [`remove_class!`](@ref) functions.

Finally, the contents of the script tag generating the plot are stored in the
field `script_contents` which is of type [`ScriptContents`](@ref). The elements
of `script_contents` are written serially inside the javascript script tag. The
displayed plot can be customized by modifying the elements of this field.

# Examples
```julia
p = PlutoPlot(Plot(rand(10)))
add_plotly_listener!(p, "plotly_click", "e => console.log(e)")
add_class!(p, "custom_class")
```

See also: [`ScriptContents`](@ref), [`add_js_listener!`](@ref), [`add_plotly_listener!`](@ref)
"""
Base.@kwdef struct PlutoPlot
	Plot::PlotlyBase.Plot
	plotly_listeners::Dict{String, Vector{String}} = Dict{String, Vector{String}}()
	js_listeners::Dict{String, Vector{String}} = Dict{String, Vector{String}}()
	classList::Vector{String} = String[]
	script_contents::SCType = deepcopy(_default_script_contents)
end
PlutoPlot(p::PlotlyBase.Plot; kwargs...) = PlutoPlot(;kwargs..., Plot = p)

# Getter that extract the underlying Plot object data
function Base.getproperty(p::PlutoPlot, s::Symbol)
	if hasfield(Plot, s)
		getfield(getfield(p, :Plot), s)
	else
		getfield(p, s)
	end
end

function plot(args...;kwargs...) 
	@nospecialize
	PlutoPlot(Plot(args...;kwargs...))
end