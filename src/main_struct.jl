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
			background: var(--main-bg-color);
			display: flex;
			border: 3px solid var(--kbd-border-color);
			border-top-left-radius: 12px;
			border-top-right-radius: 12px;
			position: fixed;
			z-index: 1001;
			cursor: move;
			transform: translate(0px, -100%);
			padding: 5px;
		}
		.plutoplotly-clipboard-header > span {
			display: inline-block;
			flex: 1
		}
		.plot-scale > span {
			cursor: text;
		}
		.plutoplotly-clipboard-header.hidden {
			display: none;
		}
	</style>
	`)
	""",
	"""
	let original_height = plot_obj.layout.height
	let original_width = plot_obj.layout.width
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	// We define a variable to check whether we still have to remove the fixed height
	let remove_container_height = firstRun
	let container_height = original_height ?? PLOT.container_height ?? 400
	CONTAINER.style.height = container_height + 'px'
	""",
	clipboard_script,
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
	function computeSize() {
		let plot_cs = window.getComputedStyle(PLOT, null);
		// Remove Padding
		let plot_pad = {
			paddingX: parseFloat(plot_cs.paddingLeft) + parseFloat(plot_cs.paddingRight),
			paddingY: parseFloat(plot_cs.paddingTop) + parseFloat(plot_cs.paddingBottom),
			borderX: parseFloat(plot_cs.borderLeftWidth) + parseFloat(plot_cs.borderRightWidth),
			borderY: parseFloat(plot_cs.borderTopWidth) + parseFloat(plot_cs.borderBottomWidth),
			offsetTop: PLOT.offsetParent == CONTAINER ? PLOT.offsetTop : 0,
			offsetLeft: PLOT.offsetParent == CONTAINER ? PLOT.offsetLeft : 0
		}
		let container_cs = window.getComputedStyle(CONTAINER, null);
		let container_pad = {
			paddingX: parseFloat(container_cs.paddingLeft) + parseFloat(container_cs.paddingRight),
			paddingY: parseFloat(container_cs.paddingTop) + parseFloat(container_cs.paddingBottom),
			borderX: parseFloat(container_cs.borderLeftWidth) + parseFloat(container_cs.borderRightWidth),
			borderY: parseFloat(container_cs.borderTopWidth) + parseFloat(container_cs.borderBottomWidth),
		}
		let rect = CONTAINER.getBoundingClientRect()
		// We save the height in the PLOT object
		PLOT.container_height = rect.height
		if (remove_container_height) {
			// This is needed to avoid the first resize upon plot creation to already be without a fixed height
			CONTAINER.style.height = ''
			remove_container_height = false
		}
		const sz = {
			width: rect.width - plot_pad.paddingX - plot_pad.borderX - plot_pad.offsetLeft - container_pad.paddingX - container_pad.borderX,
			height: rect.height - plot_pad.paddingY - plot_pad.borderY - plot_pad.offsetTop - container_pad.paddingY - container_pad.borderY,
		}
		CLIPBOARD_HEADER.style.width = rect.width + 'px'
		CLIPBOARD_HEADER.style.left = rect.left + 'px'
		value_spans.height.innerText = sz.height
		value_spans.width.innerText = sz.width
		return sz
	}

	// Create the resizeObserver to make the plot even more responsive! :magic:
	const resizeObserver = new ResizeObserver(entries => {
		let size = computeSize()
		/* 
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking. 
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
		let config = {
			width: original_width ?? size.width,
			height: original_height ?? size.height,
			plutoresize: true,
		}
		Plotly.relayout(PLOT, config).then(() => {
		})
	})

	resizeObserver.observe(CONTAINER)
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