const PLOTLY_VERSION = Ref("2.26.1")

const SCType = Dictionary{String, Union{Function, Script}}

# This will contain the default contents of the script generating the plot
const _default_script_contents = SCType()

# We declare it here but define it later
function _load_data_JS end

set!(_default_script_contents, "publish_to_js", _load_data_JS)

# Preamble
set!(_default_script_contents, "PLOT variable", DualScript(
	# This is rendered inside of Pluto
	PlutoScript("""
	// Flag to check if this cell was  manually ran or reactively ran
	const firstRun = this ? false : true
	const PLOT = this ?? document.createElement("div");
	const parent = currentScript.parentElement
	const isPlutoWrapper = parent.classList.contains('raw-html-wrapper')

	if (firstRun) {
		// It seem plot divs would not autosize themself inside flexbox containers without this
		parent.appendChild(PLOT)
	}
	"""),
	# This is rendered outside of Pluto
	NormalScript("""
	const PLOT = document.createElement("div")
	""")
))

# Adjust width/height
set!(_default_script_contents, "adjust widht/height", DualScript(
	# This is rendered inside of Pluto
	PlutoScript("""
	// If width is not specified, set it to 100%
	PLOT.style.width = plot_obj.layout.width ? "" : "100%"
	
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	PLOT.style.height = plot_obj.layout.height ? "" :
		(isPlutoWrapper || parent.clientHeight == 0) ? "400px" : "100%"
	"""),
	# This is rendered outside of Pluto
	NormalScript()
))

# classlist
set!(_default_script_contents, "classlist", DualScript(
	# This is rendered inside of Pluto
	PlutoScript("""
	PLOT.classList.forEach(cn => {
		// This is necessary for cleaning up the classlist
		if (cn !== 'js-plotly-plot' && !custom_classlist.includes(cn)) {
			PLOT.classList.toggle(cn, false)
		}
	})
	for (const className of custom_classlist) {
		PLOT.classList.toggle(className, true)
	}
	"""),
	# This is rendered outside of Pluto
	NormalScript("""
	for (const className of custom_classlist) {
		PLOT.classList.toggle(className, true)
	}
	""")
))

# resizeObserver
set!(_default_script_contents, "resizeObserver", DualScript(
	# This is rendered inside of Pluto
	PlutoScript(;
	body = """
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
	invalidation = """
		// Remove the resizeObserver
		resizeObserver.disconnect()
	"""),
	# This is rendered outside of Pluto
	NormalScript()
))

# Plotly.react
set!(_default_script_contents, "Plotly.react", let
	# This is rendered inside of Pluto
	ps = PlutoScript(;
	body = """
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
	invalidation = """
		// Remove all plotly listeners
		PLOT.removeAllListeners()
		// Remove all JS listeners
		for (const [key, listener_vec] of Object.entries(js_listeners)) {
			for (const listener of listener_vec) {
				PLOT.removeEventListener(key, listener)
			}
		}
	""")
	# Outside of Pluto we simply re-use the body
	ns = NormalScript(ps.body)
	DualScript(ps, ns)
end)

set!(_default_script_contents, "returned_element", DualScript(""; returned_element = "PLOT"))

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

_pluto_default_iocontext() = try
	Main.PlutoRunner.default_iocontext 
catch
	IOContext(devnull)
end

# Create a ScriptContent using the IOContext from PlutoRunner (to avoid breaking core_publish_to_js)
_pluto_sc(h::HypertextLiteral.Result) = ScriptContent(h; iocontext = _pluto_default_iocontext())

# Load data from the PlutoPlot object to JavaScript
function _load_data_JS(pp::PlutoPlot; script_id = "pluto-plotly-div", ver = PLOTLY_VERSION[], kwargs...)
	common = @htl("""
	<script>
		// Publish the plot object to JS
		let plot_obj = $pp
		// Get the plotly listeners
		const plotly_listeners = $(pp.plotly_listeners)
		// Get the JS listeners
		const js_listeners = $(pp.js_listeners)
		// Deal with eventual custom classes
		let custom_classlist = $(pp.classList)

		// Load the plotly library
		let Plotly = undefined
		try {
			let _mod = await import($(get_plotly_src("$ver", "local")))
			Plotly = _mod.default
		} catch (e) {
			console.log("Local load failed, trying with the web esm.sh version")
			let _mod = await import($(get_plotly_src("$ver", "esm")))
			Plotly = _mod.default
		}
	</script>
	""") 
	ps = PlutoScript(@htl("""
	<script>
		$(common |> _pluto_sc)
		// Check if we have to force local mathjax font cache
		if ($(force_pluto_mathjax_local()) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}
	</script>
	""") |> _pluto_sc)
	ns = NormalScript(ScriptContent(common))
	return DualScript(ps, ns; id = script_id)
end