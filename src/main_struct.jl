# This is only used to simplify debugging (by setting this to false) the plotly internal functions using the developer console
const LOAD_MINIFIED = Ref(true)
const PLOTLY_VERSION = Ref("2.25.1")
const JS = HypertextLiteral.JavaScript

"""
	ScriptContents
Wrapper around a vector of `HypertextLiteral.JavaScript` elements. It has a custom print implementation of `HypertextLiteral.print_script` in order to allow serialization of its various elements inside a script tag.

It is used inside the PlutoPlot to allow modularity and ease customization of the script contents that is used to generate the plotlyjs plot in Javascript.
"""
struct ScriptContents
	vec::Vector{JS}
end

function HypertextLiteral.print_script(io::IO, value::ScriptContents)
	for el ∈ value.vec
		print(io, el.content, '\n')
	end
end

"""
	htl_js(x)
Simple convenience constructor for `HypertextLiteral.JavaScript` objects, renamed and re-exported from HypertextLiteral for convenience in case HypertextLiteral is not explicitly loaded alongisde PlutoPlotly.

See also: [`add_plotly_listeners!`](@ref)
"""
htl_js(x) = HypertextLiteral.JavaScript(x)

const _default_script_contents = htl_js.([
	"""
	// Flag to check if this cell was  manually ran or reactively ran
	const firstRun = this ? false : true
	const PLOT = this ?? document.createElement("div");
	const parent = currentScript.parentElement
	const isPlutoWrapper = parent.classList.contains('raw-html-wrapper')
	""",
	"""
	if (firstRun) {
		// It seem plot divs would not autosize themself inside flexbox containers without this
		parent.appendChild(PLOT)
	}
	""",
	"""
	// If width is not specified, set it to 100%
	PLOT.style.width = plot_obj.layout.width ? "" : "100%"
	
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	PLOT.style.height = plot_obj.layout.height ? "" :
		(isPlutoWrapper || parent.clientHeight == 0) ? "400px" : "100%"
	""",
	"""


	PLOT.classList.forEach(cn => {
		if (cn !== 'js-plotly-plot' && !custom_classlist.includes(cn)) {
			PLOT.classList.toggle(cn, false)
		}
	})
	for (const className of custom_classlist) {
		PLOT.classList.toggle(className, true)
	}
	""",
	"""

	// Create the resizeObserver to make the plot even more responsive! :magic:
	const resizeObserver = new ResizeObserver(entries => {
		PLOT.style.height = plot_obj.layout.height ? "" :
		(isPlutoWrapper || parent.clientHeight == 0) ? "400px" : "100%"
		/* 
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking. 
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
		Plotly.relayout(PLOT, {..._.pick(PLOT.layout, ['width','height']), autosize: true, plutoresize: true})
	})

	resizeObserver.observe(PLOT)
	""",
	"""

	Plotly.react(PLOT, plot_obj).then(() => {
		// Assign the Plotly event listeners
		for (const [key, listener_vec] of Object.entries(plotly_listeners)) {
			for (const listener of listener_vec) {
				PLOT.on(key, listener)
			}
		}
		// Assign the JS event listeners
		for (const [key, listener_vec] of Object.entries(js_listeners)) {
			for (const listener of listener_vec) {
				PLOT.addEventListener(key, listener)
			}
		}
	}
	)
	""",
	"""

	invalidation.then(() => {
		// Remove all plotly listeners
		PLOT.removeAllListeners()
		// Remove all JS listeners
		for (const [key, listener_vec] of Object.entries(js_listeners)) {
			for (const listener of listener_vec) {
				PLOT.removeEventListener(key, listener)
			}
		}
		// Remove the resizeObserver
		resizeObserver.disconnect()
	})
	""",
])

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
	plotly_listeners::Dict{String, Vector{JS}} = Dict{String, Vector{JS}}()
	js_listeners::Dict{String, Vector{JS}} = Dict{String, Vector{JS}}()
	classList::Vector{String} = String[]
	script_contents::ScriptContents = ScriptContents(deepcopy(_default_script_contents))
end
PlutoPlot(p::PlotlyBase.Plot; kwargs...) = PlutoPlot(;kwargs..., Plot = p)

function plot(args...;kwargs...) 
	@nospecialize
	PlutoPlot(Plot(args...;kwargs...))
end