const _default_script_contents = htl_js.([
	"""
	// Flag to check if this cell was  manually ran or reactively ran
	const firstRun = this ? false : true
	const CONTAINER = this ?? html`<div class='plutoplotly-container'>`
	const PLOT = CONTAINER.querySelector('.js-plotly-plot') ?? CONTAINER.appendChild(html`<div>`)
	const parent = CONTAINER.parentElement
	// We use a controller to remove event listeners upon invalidation
	const controller = new AbortController()
	// We have to add this to keep supporting @bind with the old API using PLOT
	PLOT.addEventListener('input', (e) => {
		CONTAINER.value = PLOT.value
		if (e.bubbles) {
			return
		}
		CONTAINER.dispatchEvent(new CustomEvent('input'))
	}, { signal: controller.signal })
	""",
	"""
		// This create the style subdiv on first run
		firstRun && CONTAINER.appendChild(html`
		<style>
		.plutoplotly-container {
			width: 100%;
			height: 100%;
			min-height: 0;
			min-width: 0;
		}
		.plutoplotly-container .js-plotly-plot .plotly div {
			margin: 0 auto; // This centers the plot
		}
		.plutoplotly-container.popped-out {
			overflow: auto;
			z-index: 1000;
			position: fixed;
			resize: both;
			background: var(--main-bg-color);
			border: 3px solid var(--kbd-border-color);
			border-radius: 12px;
			border-top-left-radius: 0px;
			border-top-right-radius: 0px;
		}
		.plutoplotly-clipboard-header {
			display: flex;
			flex-flow: row wrap;
			background: var(--main-bg-color);
			border: 3px solid var(--kbd-border-color);
			border-top-left-radius: 12px;
			border-top-right-radius: 12px;
			position: fixed;
			z-index: 1001;
			cursor: move;
			transform: translate(0px, -100%);
			padding: 5px;
		}
		.plutoplotly-clipboard-header span {
			display: inline-block;
			flex: 1
		}
		.plutoplotly-clipboard-header.hidden {
			display: none;
		}
		.clipboard-span {
			position: relative;
		}
		.clipboard-value {
			padding-right: 5px;
			padding-left: 2px;
			cursor: text;
		}
		.clipboard-span.format {
			display: none;
		}
		.clipboard-span.filename {
			flex: 0 0 100%;
			text-align: center;
			border-top: 3px solid var(--kbd-border-color);
			margin-top: 5px;
			display: none;
		}
		.plutoplotly-container.filesave .clipboard-span.filename {
			display: inline-block;
		}
		.clipboard-value.filename {
			margin-left: 3px;
			text-align: left;
			min-width: min(60%, min-content);
		}
		.plutoplotly-container.filesave .clipboard-span.format {
			display: inline-flex;
		}
		.clipboard-span.format .label {
			flex: 0 0 0;
		}
		.clipboard-value.format {
			position: relative;
			flex: 1 0 auto;
			min-width: 30px;
			margin-right: 10px;
		}
		div.format-options {
			display: inline-flex;
			flex-flow: column;
			position: absolute;
			background: var(--main-bg-color);
			border-radius: 12px;
			padding-left: 3px;
			z-index: 2000;
		}
		div.format-options:hover {
			cursor: pointer;
			border: 3px solid var(--kbd-border-color);
			padding: 3px;
			transform: translate(-3px, -6px);
		}
		div.format-options .format-option {
			display: none;
		}
		div.format-options:hover .format-option {
			display: inline-block;
		}
		.format-option:not(.selected) {
			margin-top: 3px;
		}
		div.format-options .format-option.selected {
			order: -1;
			display: inline-block;
		}
		.format-option:hover {
			background-color: var(--kbd-border-color);
		}
		span.config-value {
			font-weight: normal
			color: var(--pluto-output-color);
			display: none;
			position: absolute;
			background: var(--main-bg-color);
			border: 3px solid var(--kbd-border-color);
			border-radius: 12px;
			transform: translate(0px, -120%);
			padding: 5px;
		}
		.label:hover span.config-value {
			display: inline-block;
			min-width: 150px;
		}
		.clipboard-span.matching-config .label {
			color: var(--cm-macro-color);
			font-weight: bold;
		}
		.clipboard-span.different-config .label {
			color: var(--cm-tag-color);
			font-weight: bold;
		}
	</style>
	`)
	""",
	"""
	let original_height = plot_obj.layout.height
	let original_width = plot_obj.layout.width
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	// We define a variable to check whether we still have to remove the fixed height
	let remove_container_size = firstRun
	let container_height = original_height ?? PLOT.container_height ?? 400
	CONTAINER.style.height = container_height + 'px'
	""",
	clipboard_script,
	resizer_script,
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
				PLOT.addEventListener(key, listener, {
					signal: controller.signal
				})
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
		controller.abort()
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