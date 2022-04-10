### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7b8a4360-aaa4-11ec-2efc-b1778f6d3a8c
begin
	using PlotlyBase
	using HypertextLiteral
end

# ╔═╡ 810fb486-10b5-460f-a25a-1a7c9d84e256
using LaTeXStrings

# ╔═╡ 676d318f-b4a4-4949-a5db-1c3a5fd9fa68
using AbstractPlutoDingetjes

# ╔═╡ fc52e423-1370-4ca9-95dc-090815278a4a
using PlutoUI

# ╔═╡ 7bd46437-8af0-4a15-87e9-1508869e1600
TableOfContents()

# ╔═╡ 4a18fa5d-7c73-468b-bed2-3acff51e3981
publish_to_js = if is_inside_pluto()
	PlutoRunner.publish_to_js
else
	# @warn "You loaded this package outside of Pluto, this is not the intended behavior and you should use either PlotlyBase or PlotlyJS directly"
	x -> x
end

# ╔═╡ 0ae3f943-4f9b-4cfb-aa76-3bcdc7dc9963
"""
	htl_js(x)
Simple convenience constructor for `HypertextLiteral.JavaScript` objects, renamed and re-exported from HypertextLiteral for convenience in case HypertextLiteral is not explicitly loaded alongisde PlutoPlotly.

See also: [`add_plotly_listeners!`](@ref)
"""
htl_js(x) = HypertextLiteral.JavaScript(x)

# ╔═╡ 90fd960f-65b3-4d8c-b8a8-42d3be8c770f
function Base.show(io::IO, mime::MIME"text/html", s::HypertextLiteral.JavaScript)
if is_inside_pluto()
	show(io, mime, Markdown.MD(Markdown.Code("js",s.content)))
else
	show(io, MIME"text/plain",s)
end
end

# ╔═╡ e9d43bc6-390e-43c3-becb-d1584202da41
# This is only used to simplify debugging (by setting this to false) the plotly internal functions using the developer console
const LOAD_MINIFIED = Ref(true)

# ╔═╡ 16f4b455-086b-4a8b-8767-26fb00a77aad
md"""
# Utility Functions
"""

# ╔═╡ 03bf1bc5-37a9-4b02-bff7-f8b42500c4fc
const JS = HypertextLiteral.JavaScript

# ╔═╡ c3dcd4d9-5e57-4189-a7f8-524afd6db1e6
md"""
## Hyperscript.content hack!
"""

# ╔═╡ 6a4a5cc2-dca5-4f5d-a7e2-9b1f2fbaa406
md"""
## ScriptContents struct
"""

# ╔═╡ 441b20b3-ef9a-4d8a-a6b0-6b6be151a3dd
struct ScriptContents
	vec::Vector{JS}
end

# ╔═╡ 271fd3a7-8347-407d-92d0-2d49758cb3f1
function HypertextLiteral.print_script(io::IO, value::ScriptContents)
	for el ∈ value.vec
		print(io, el.content, '\n')
	end
end

# ╔═╡ 907d51fd-9aaf-43d0-a83b-879cae330a0b
md"""
## Plotly Version
"""

# ╔═╡ 10da78b9-9a67-4cd8-9453-c01ea4baabeb
const PLOTLY_VERSION = Ref("2.11.1")

# ╔═╡ ea88edae-c1a1-4cd3-95da-fd6d5cf337ff
function change_plotly_version(ver::String)
	PLOTLY_VERSION[] = ver
end

# ╔═╡ 5e5cf476-609c-4669-bf5d-c3fc3b75b2fe
get_plotly_version() = PLOTLY_VERSION[]

# ╔═╡ 0c84069c-8362-43e7-8f0f-10f445ddc7fd
check_plotly_version() = @htl """
<script>
	let dv = document.createElement('div')
	let ver = window.Plotly?.version
	if (!ver) {
		dv.innerHTML = "Plotly not loaded!"
		return dv
	}
	if (ver === $(PLOTLY_VERSION[])) {
		dv.innerHTML = ver
	} else {
		dv.innerHTML = "The loaded Plotly version (" + ver + ") is different from the one specified in the package ($(HypertextLiteral.JavaScript(PLOTLY_VERSION[]))), reload the browser page to use the version from PlutoPlotly"
	}
	return dv
	
</script>
"""

# ╔═╡ 83f2fe95-a6c2-42ec-ac86-72a4b4ec95c3
md"""
## Mathjax hack
"""

# ╔═╡ 4b1688b2-677e-41be-9446-e395925a7311
const FORCE_MATHJAX_LOCAL = Ref(false)

# ╔═╡ 49cf85b1-bf09-49de-8468-4e240dc621fa
"""
	force_pluto_mathjax_local::Bool
	force_pluto_mathjax_local(flag::Bool)::Bool

Returns `true` if the `PlutoPlot` `show` method forces svgs produced by MathJax to be locally cached and `false` otherwise.

The flag can be set at package level by providing the intended boolean value as argument to the function

Local svg caching is used to make mathjax in recent plolty versions (>2.10) work as expected. The default `global` caching in Pluto creates problems with the math display.
"""
force_pluto_mathjax_local() = FORCE_MATHJAX_LOCAL[]

# ╔═╡ 997f1421-b2f7-40c2-bc5b-f8a21cb4b04a
force_pluto_mathjax_local(flag::Bool) = FORCE_MATHJAX_LOCAL[] = flag

# ╔═╡ e6b52b32-def4-4d71-80ca-e43530b1e704
md"""
## Preprocess data
"""

# ╔═╡ 77fe2c5d-f3dd-4779-92a4-e0ceadb639a9
md"""
This function is basically `_json_lower` from PlotlyBase, but we do it directly on the PlutoPlot to avoid the modifying the behavior of `_json_lower` for `Plot` objects (which is required to modify how matrices are passed to `publish_to_js`)
"""

# ╔═╡ 2380a265-700d-4fed-a52e-f6fa1ce41391
# Defaults to JSON.lower for generic non-overloaded types
_preprocess(x) = PlotlyBase.JSON.lower

# ╔═╡ bc727ded-8675-420d-806e-0b49357118e5
begin
	_preprocess(x::Union{Bool,String,Number,Nothing,Missing}) = x
	_preprocess(x::Union{Tuple,AbstractArray}) = _preprocess.(x)
	_preprocess(m::Matrix{<:Number}) = [collect(r) for r ∈ eachrow(m)]
	_preprocess(d::Dict) = Dict{Any,Any}(k => _preprocess(v) for (k, v) in pairs(d))
	_preprocess(a::PlotlyBase.HasFields) = Dict{Any,Any}(k => _preprocess(v) for (k, v) in pairs(a.fields))
	_preprocess(c::PlotlyBase.Cycler) = c.vals
	function _preprocess(c::PlotlyBase.ColorScheme)::Vector{Tuple{Float64,String}}
	    N = length(c.colors)
	    map(ic -> ((ic[1] - 1) / (N - 1), _preprocess(ic[2])), enumerate(c.colors))
	end
end

# ╔═╡ f9c0a331-1f1c-4648-9c24-5e9e16d6be18
_preprocess(t::PlotlyBase.Template) = Dict(
    :data => _preprocess(t.data),
    :layout => _preprocess(t.layout)
)

# ╔═╡ b0d77b4f-da8f-4a0b-a244-043b2e3bdfae
function _preprocess(pc::PlotlyBase.PlotConfig)
    out = Dict{Symbol,Any}()
    for fn in fieldnames(PlotlyBase.PlotConfig)
        field = getfield(pc, fn)
        if !isnothing(field)
            out[fn] = field
        end
    end
    out
end

# ╔═╡ b8e1b177-6686-4b58-8c4c-991d9c148520
# Escape latexstrings
_preprocess(s::LaTeXString) = s.s

# ╔═╡ 4e296bdd-cbd4-4d43-a769-0b4a80d7dec9
md"""
## Unique Counter
"""

# ╔═╡ 628c6e1f-03eb-43a2-8092-a2f61cf6bcbd
function unique_io_counter(io::IO, identifier = "script_id")
	!get(io, :is_pluto, false) && return -1 # We simply return -1 if not inside pluto
	# By default pluto inserts a dict inside the IOContext under key :extra_items. See https://github.com/fonsp/Pluto.jl/blob/10747db7ed512c6b3a9881c5cdb2a4daadea766d/src/runner/PlutoRunner.jl#L786
	dict = io.dict[:extra_items]
	# The dict has key of type Tuple{ObjectID, Int64}, so we a custom key with our custom identifier where we will store the counter 
	key = (objectid(identifier), 0)
	counter = get(dict, key, 0) + 1
	# Update the counter on the dict that is shared within this IOContext
	dict[key] = counter
end

# ╔═╡ ebcc9c42-9928-4a20-a307-02ee6ef726d0
# Using the unique_io_counter inside the show3 method allows to have unique counters for plots within a same cell.
# This does not ensure that the same plot object is always given the same unique script id if the plots are added to the cells with `if...end` blocks.
function plotly_script_id(io::IO)
	counter = unique_io_counter(io, "plotly-plot")
	return "plot_$counter"
end

# ╔═╡ fa975cb6-4ec1-419a-bcd6-527c0762a533
md"""
# Plot Wrapper
"""

# ╔═╡ 8b57581f-65b3-4edf-abe3-9dfa4ed82ed5
md"""
We define a wrapper around the PlotlyBase.Plot object
"""

# ╔═╡ f5491a94-5ea8-4459-b6ee-5d37f2ba6188
md"""
## Default script contents
"""

# ╔═╡ 92f5a728-6c57-47b7-9929-e2e19f91da2f
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
	PLOT.style.height = plot_obj.layout.height ? plot_obj.layout.height + "px" :
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
		/* 
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking. 
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
		Plotly.relayout(PLOT, {autosize: true, plutoresize: true})
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

# ╔═╡ 656e982b-d805-4a75-b3e6-53a4444e5374
md"""
## Struct definition
"""

# ╔═╡ 0f088a21-7d5f-43f7-b99f-688338b61dc6
begin
"""
	PlutoPlot(p::Plot; kwargs...)

A wrapper around `PlotlyBase.Plot` to provide optimized visualization within Pluto notebooks exploiting `@htl` from HypertextLiteral.

# Fields
- `Plot::PlotlyBase.Plot`
- `plotly_listeners::Dict{String, Vector{HypertextLitera.JavaScript}}`
- `classList::Vector{String}`

Once the wrapper has been created, the underlying `Plot` object can be accessed from the `Plot` field of the `PlutoPlot` object.

Custom listeners to [plotly events](https://plotly.com/javascript/plotlyjs-events/) can be added to the `PlutoPlot` as *javascript* functions using the [`add_plotly_listener!`](@ref) function.

Multiple listeners can be associated to each event, and they are executed in the order they are added.

A list of custom CSS classes can be added to the PlutoPlot by using the [`add_class!`](@ref) and [`remove_class!`](@ref) functions.

# Examples
```julia
p = PlutoPlot(Plot(rand(10)))
add_plotly_listener!(p, "plotly_click", "e => console.log(e)")
add_class!(p, "custom_class")
```
"""
Base.@kwdef struct PlutoPlot
	Plot::PlotlyBase.Plot
	plotly_listeners::Dict{String, Vector{JS}} = Dict{String, Vector{JS}}()
	js_listeners::Dict{String, Vector{JS}} = Dict{String, Vector{JS}}()
	classList::Vector{String} = String[]
	script_contents::ScriptContents = ScriptContents(deepcopy(_default_script_contents))
end
PlutoPlot(p::PlotlyBase.Plot; kwargs...) = PlutoPlot(;kwargs..., Plot = p)
end

# ╔═╡ 214cae09-fb98-4ca8-8475-62563e31f665
# This is needed till next version of HypertextLiteral is out (current is 0.9.3). See https://github.com/JuliaPluto/HypertextLiteral.jl/issues/28 for details
HypertextLiteral.content(p::PlutoPlot) = HypertextLiteral.Render(p)

# ╔═╡ 1686debe-6d74-4ec5-bf25-12346c8045c2
function push_script!(p::PlutoPlot, items::Vararg{String,N}) where N
	@nospecialize
	push!(p.script_contents.vec, htl_js.(items)...)
	return p
end

# ╔═╡ 64ce91b4-aaa3-45ec-b4d6-f24457167667
function _preprocess(pp::PlutoPlot)
	p = pp.Plot
    out = Dict(
        :data => _preprocess(p.data),
        :layout => _preprocess(p.layout),
        :frames => _preprocess(p.frames),
        :config => _preprocess(p.config)
    )

    if templates.default !== "none" && PlotlyBase._isempty(get(out[:layout], :template, Dict()))
        out[:layout][:template] = _preprocess(templates[templates.default])
    end
    out
end

# ╔═╡ 4ebd0ae4-9f4f-42b2-980e-a25550d01b6b
md"""
## Add plotly listeners
"""

# ╔═╡ de2a547b-3ccd-4f56-96c0-81a7d9b2d272
"""
	add_plotly_listener!(p::PlutoPlot, event_name::String, listener::HypertextLiteral.JavaScript)
	add_plotly_listener!(p::PlutoPlot, event_name::String, listener::String)

Add a custom *javascript* `listener` (to be provided as `String` or directly as `HypertextLiteral.JavaScript`) to the `PlutoPlot` object `p`, and associated to the [plotly event](https://plotly.com/javascript/plotlyjs-events/) specified by `event_name`.

The listeners are added to the HTML plot div after rendering. The div where the plot is inserted can be accessed using the variable named `PLOT` inside the listener code.

# Differences with `add_js_listener!`
This function adds a listener using the plotly internal events via the `on` function. These events differ from the standard javascript ones and provide data specific to the plot.

See also: [`add_js_listener!`](@ref), [`htl_js`](@ref)

# Examples:
```julia
p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
add_plotly_listener!(p, "plotly_relayout", htl_js(\"\"\"
function(e) {

console.log(PLOT) // logs the plot div inside the developer console

}
\"\"\"
```
"""
function add_plotly_listener!(p::PlutoPlot, event_name::String, listener::JS)
	ldict = p.plotly_listeners
	listeners_array = get!(ldict, event_name, JS[])
	push!(listeners_array, listener)
	return p
end;

# ╔═╡ 35e643ab-e3ea-427b-85f2-685b6b6103b8
add_plotly_listener!(p::PlutoPlot, event_name, listener::String) = add_plotly_listener!(p, event_name, htl_js(listener))

# ╔═╡ 3cc48426-1c39-4afe-bf3e-7f4aa2197fca
md"""
## Add JS listeners
"""

# ╔═╡ 67137f84-a284-4615-b7a8-729f0a412939
"""
	add_js_listener!(p::PlutoPlot, event_name::String, listener::HypertextLiteral.JavaScript)
	add_js_listener!(p::PlutoPlot, event_name::String, listener::String)

Add a custom *javascript* `listener` (to be provided as `String` or directly as `HypertextLiteral.JavaScript`) to the `PlutoPlot` object `p`, and associated to the javascript event specified by `event_name`.

The listeners are added to the HTML plot div after rendering. The div where the plot is inserted can be accessed using the variable named `PLOT` inside the listener code.

# Differences with `add_plotly_listener!`
This function adds standard javascript events via the `addEventListener` function. These events differ from the plotly specific events.

See also: [`add_plotly_listener!`](@ref), [`htl_js`](@ref)

# Examples:
```julia
p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
add_js_listener!(p, "mousedown", htl_js(\"\"\"
function(e) {

console.log(PLOT) // logs the plot div inside the developer console when pressing down the mouse

}
\"\"\"
```
"""
function add_js_listener!(p::PlutoPlot, event_name::String, listener::JS)
	ldict = p.js_listeners
	listeners_array = get!(ldict, event_name, JS[])
	push!(listeners_array, listener)
	return p
end;

# ╔═╡ 83906aab-d4ac-4c2b-b7a4-718edb0c2a18
add_js_listener!(p::PlutoPlot, event_name, listener::String) = add_js_listener!(p, event_name, htl_js(listener))

# ╔═╡ 0215aea2-eb79-449e-8dee-a32ca3c5d5f9
md"""
## add_class!
"""

# ╔═╡ 4c6a1004-52ca-40c1-915a-081c0a3c5fbf
"""
	add_class!(p::PlutoPlot, className::String)

Add a CSS class with name `className` to the list of custom classes that are added to the PLOT div when displayed inside Pluto. This can be used to give custom CSS styles to certain plots.

See also: [`remove_class!`](@ref)
"""
function add_class!(p::PlutoPlot, className::String)
	cl = p.classList
	if className ∉ cl
		push!(cl, className)
	end
	return p
end

# ╔═╡ 87af8c6f-3d6d-44c6-87bb-588e01829339
md"""
## remove_class!
"""

# ╔═╡ 50077612-a858-48a0-a187-a9de1489f34f
"""
	remove_class!(p::PlutoPlot, className::String)

Remove a CSS class with name `className` (if present) from the list of custom classes that are added to the PLOT div when displayed inside Pluto. This can be used to give custom CSS styles to certain plots.

See also: [`add_class!`](@ref)
"""
function remove_class!(p::PlutoPlot, className::String)
	cl = p.classList
	idx = findfirst(x -> x === className, cl)
	if idx !== nothing
		deleteat!(cl, idx)
	end
	return p
end

# ╔═╡ 49fe75d5-844d-46d5-a251-7023706a7f92
let
	p = PlutoPlot(Plot())
	add_class!(p, "lol")
	remove_class!(p, "lola")
	p.classList
end

# ╔═╡ 73290c37-481a-4f7d-a92d-038766702890
md"""
# plot Method
"""

# ╔═╡ c3fcc72a-389c-456a-aba5-cbfb4a798c9e
function plot(args...;kwargs...) 
	@nospecialize
	PlutoPlot(Plot(args...;kwargs...))
end

# ╔═╡ f6a63433-553c-4857-b767-33465eb22934
let
	p = plot(rand(10,4))
	asd = p.script_contents
	push!(asd,htl_js("console.log('SANTA MADRE')"))
	p
end

# ╔═╡ 18e74f8f-39b6-4c8f-a06f-214d4e9dc6fb
plot(scatter(x = 1:10, y = rand(10)), Layout(title = "TITLE", template = "none"))

# ╔═╡ 8a047414-cd5d-4491-a143-eb30578928ce
md"""
# Show Method
"""

# ╔═╡ f9d1e69f-7a07-486d-b43a-334c1c77790a
function _show(pp::PlutoPlot, script_id = "pluto-plotly-div")
ver = htl_js(PLOTLY_VERSION[])
suffix = htl_js(LOAD_MINIFIED[] ? "min.js" : "js")
@htl """
	<script id=$(script_id)>
		// We start by putting all the variable interpolation here at the beginning

		// Publish the plot object to JS
		let plot_obj = $(publish_to_js(_preprocess(pp)))
		// Get the plotly listeners
		const plotly_listeners = $(pp.plotly_listeners)
		// Get the JS listeners
		const js_listeners = $(pp.js_listeners)
		// Deal with eventual custom classes
		let custom_classlist = $(pp.classList)

		// Load the plotly library
		if (!window.Plotly) {
			const {plotly} = await import('https://cdn.plot.ly/plotly-$(ver).$(suffix)')
		}

		// Check if we have to force local mathjax font cache
		if ($(force_pluto_mathjax_local()) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}

		$(pp.script_contents)

		return PLOT
	</script>
"""
end

# ╔═╡ d42d4694-e05d-4e0e-a198-79a3a5cb688a
function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, _show(plt, plotly_script_id(io)))
	# show(io, mime, _show(plt))
end

# ╔═╡ acba5003-a456-4c1a-a53f-71a3bec30251
md"""
# Tests
"""

# ╔═╡ 0c30855c-6542-4b1a-9427-3a8427e75210
md"""
## Slider + UIRevision
"""

# ╔═╡ de0cb780-ff4e-4236-89c4-4c3163337cfc
@bind clk Clock()

# ╔═╡ dd23fe10-a8d5-461a-85a8-e03468cdcd97
# @bind N Slider(50:50:250)
N =let 
	clk
	rand(50:100)
end

# ╔═╡ 6da3c910-a350-4a7e-b481-88942c97686b
"""
	push_script!(p::PlutoPlot, items...)
Add script contents contained in collection `items` at the end of the plot show method script.
The `item` must either be a collection of `String` or `HypertextLiteral.JavaScript` elements
"""
function push_script!(p::PlutoPlot, items::Vararg{JS,N}) where N
	@nospecialize
	push!(p.script_contents.vec, items...)
	return p
end

# ╔═╡ fdc22972-b8aa-4202-bb4e-bfff92574814
let
	p = plot(rand(4))
	push_script!(p, "console.log('PUSHED')")
end

# ╔═╡ 8bf75ceb-e4ae-4c6c-8ab0-a81350f19bc7
pp = Plot(scatter3d(x = rand(N), y = rand(N), z = rand(N), mode="markers"), Layout(
	uirevision = 1,
	scene = attr(
		xaxis_range = [-1,2],
		yaxis_range = [-1,2],
		zaxis_range = [-1,2],
		aspectmode = "cube",
	),
	height = 550
	# autosize = true,
));

# ╔═╡ ccf62e33-8fcf-45d9-83ed-c7de80800b76
let
	p = PlutoPlot(pp)
	add_plotly_listener!(p, "plotly_relayout", htl_js("""
	(e) => {

	console.log(e)
	//console.log(PLOT._fullLayout._preGUI)
    
    
	var eye = e['scene.camera']?.eye;

    if (eye) {
		console.log('update: ', eye);
	} else {
		console.log(e)
	}
	console.log('div: ',PLOT._fullLayout.scene.camera.eye)
   	console.log('plot_obj: ',plot_obj.layout.scene?.camera?.eye)
	
}
	"""))
	_show(p)
end

# ╔═╡ 1460ece1-7828-4e93-ac37-e979b874b492
md"""
## @bind click
"""

# ╔═╡ 18c80ea2-0df4-40ea-bd87-f8fee463161e
@bind asdasd let
	p = PlutoPlot(Plot(scatter(y = rand(10), name = "test", showlegend=true)))
	add_plotly_listener!(p,"plotly_click", "
	(e) => {

	console.log(e)
    let dt = e.points[0]
	PLOT.value = [dt.x, dt.y]
	PLOT.dispatchEvent(new CustomEvent('input'))
}
	")
	p
end

# ╔═╡ ce29fa1f-0c52-4d38-acbd-0a96cb3b9ce6
asdasd

# ╔═╡ c3e29c94-941d-4a52-a358-c4ffbfc8cab8
md"""
## @bind filtering
"""

# ╔═╡ b0473b9a-2db5-4d03-8344-b8eaf8428d6c
points = [(rand(),rand()) for _ in 1:10000]

# ╔═╡ 73945da3-af45-41fb-9c5d-6fbba6362256
@bind limits let
	p = Plot(
		scatter(x = first.(points), y = last.(points), mode = "markers")
	)|> PlutoPlot
	add_plotly_listener!(p, "plotly_relayout", "
	e => {
	//console.log(e)
	let layout = PLOT.layout
	let asd = {xaxis: layout.xaxis.range, yaxis: layout.yaxis.range}
	PLOT.value = asd
	PLOT.dispatchEvent(new CustomEvent('input'))
	}
	")
end

# ╔═╡ ea9faecf-ecd7-483b-99ad-ede08ba05383
visible_points = let
	if ismissing(limits)
		points
	else
		xrange = limits["xaxis"]
		yrange = limits["yaxis"]
		func(x,y) = x >= xrange[1] && x <= xrange[2] && y >= yrange[1] && y <= yrange[2]
		filter(x -> func(x...), points)
	end
end

# ╔═╡ 684ef6d7-c1ae-4af3-b1bd-f54bc29d7b53
length(visible_points)

# ╔═╡ f8f7b530-1ded-4ce0-a7d9-a8c92afb95c7
md"""
## Multiple Listeners
"""

# ╔═╡ c3b1a198-ef19-4a54-9c32-d9ea32a63812
let
	p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
	add_plotly_listener!(p, "plotly_relayout", htl_js("""
function(e) {
    
	console.log('listener 1')
	
}
	"""))
	add_plotly_listener!(p, "plotly_relayout", htl_js("""
function(e) {
    
	console.log('listener 2')
	
}
	"""))
	@htl "$p"
end

# ╔═╡ e9fc2030-c2f0-48e9-a807-424039e796b2
let
	p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
	add_plotly_listener!(p, "plotly_relayout", htl_js("""
function(e) {
    
	console.log('listener 1')
	
}
	"""))
	add_plotly_listener!(p, "plotly_relayout", htl_js("""
function(e) {
    
	console.log('listener 2')
	
}
	"""))
	p.plotly_listeners
end

# ╔═╡ de101f40-27db-43ea-91ed-238502ceaaf7
md"""
## JS Listener
"""

# ╔═╡ 6c709fa0-7a53-4554-ab2a-d8181267ec93
lololol = 1

# ╔═╡ 671296b9-6743-48d6-9c4d-1beac2b505b5
let
	lololol
	p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
	add_js_listener!(p, "mousedown", htl_js("""
function(e) {
    
	console.log('MOUSEDOWN!')
	
}
	"""))
end

# ╔═╡ 6128ff76-3f1f-4144-bb3d-f44678210013
md"""
## flexbox
"""

# ╔═╡ a5823eb2-3aaa-4791-bdc8-196eac2ccf2e
@htl """
<div style='height: 400px; display: flex'>
$(Plot(rand(10)) |> PlutoPlot)

$(Plot(rand(10)) |> PlutoPlot)
</div>
"""

# ╔═╡ aaf0fe61-d5e6-4d93-8a22-7f97f1249b35
md"""
## flexbox + uirevision
"""

# ╔═╡ 6e12592d-01fe-455a-a19c-7544258b9791
voila = 1

# ╔═╡ 36c4a5b1-03f2-4f5f-b9af-822a8f7c8cdf
let
	voila
	@htl """
<div style='height: 550px; display: flex; flex-direction: column;'>
<div style='display: flex; flex: 1 1 0'>
$(Plot(rand(10), Layout(uirevision = 1)) |> PlutoPlot)

$(Plot(rand(10)) |> PlutoPlot)
</div>
<div style='display: flex; flex: 1 1 0'>
$(Plot(rand(10)) |> PlutoPlot)

$(Plot(rand(10)) |> PlutoPlot)
</div>
</div>
"""
end

# ╔═╡ 8b1ab8a6-d2a7-4a15-9690-d83ebaed5c19
html"""
<style>
	.js-plotly-plot {
		flex-grow: 1;
		flex-shrink: 1;
	}
</style>
"""

# ╔═╡ 38a81414-0bcd-4d71-af1d-fe154d2ae09a
md"""
## custom class
"""

# ╔═╡ 2dd5534f-ce46-4770-b0f3-6e16005b3a90
cl = ["test_css_class", "lol"]

# ╔═╡ f69c6955-800c-461e-b464-cab4989913f6
let
	p = PlutoPlot(Plot(rand(10)))
	for cn ∈ cl
		add_class!(p, cn)
	end
	p
end

# ╔═╡ bfe5f717-4702-4316-808a-726fefef9e7e
html"""
<style>
	.test_css_class {
		border: 2px;
		border-style: solid;
	}
</style>
"""

# ╔═╡ cb3f5ee4-5504-4337-8a8d-d45784f54c85
md"""
## Sphere
"""

# ╔═╡ e0271a15-08b5-470f-a2d2-6f064cd3a2b2
function sphere(radius, origin = [0,0,0]; N = 50)
u = range(0, 2π, N)
v = range(0, π, N)
x = [radius * cos(u) * sin(v) + origin[1] for u ∈ u, v ∈ v]
y = [radius * sin(u) * sin(v) + origin[2] for u ∈ u, v ∈ v]
z = [radius * cos(v) + origin[3] for u ∈ u, v ∈ v]
	surface(;x,y,z)
end

# ╔═╡ cb1f840f-8d99-4076-9554-7d8ba56e9865
@bind M Slider(0:90)

# ╔═╡ 22245242-80a6-4a5b-815e-39b469002f84
let
	s = sphere(1)
	r = 2
	i = 0
	# M = 90
	x = [r*cosd(M)]
	y = [r*sind(M)]
	z = [0]
	sat = scatter3d(;x,y,z, mode = "markers")
	data = [s,sat]
	plot(data, Layout(
		uirevision = 1,
		scene = attr(
		xaxis_range = [-3,3],
		yaxis_range = [-3,3],
		zaxis_range = [-3,3],
		aspectmode = "cube",
	),
	))
end

# ╔═╡ 2fa13939-eba2-4d25-b461-56be79fc1db6
md"""
# Re-execute errored cells
"""

# ╔═╡ 5a324fba-1033-4dcf-b10c-1fa4f231355c
md"""
Since we have functions defined at the bottom of the notebook, when first opening the notebook some of the tests above will error and would need to be re-executed after all the function definitions are loaded. 

To do this, we put at the bottom of the notebook a javascript function that re-executes all the errored cells
"""

# ╔═╡ 9f2c0123-7e1a-43b7-861a-d059bb28f776
# # Not really needed anymore after putting the tests at the bottom

# @htl """
# <script>
# const jlerrors = document.querySelectorAll('jlerror')
# for (const err of jlerrors) {
# 	const cell = err.closest('pluto-cell')
# 	const runbut = cell.querySelector('button.runcell')
# 	runbut.click()
# }
# </script>
# """

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractPlutoDingetjes = "6e696c72-6542-2067-7265-42206c756150"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractPlutoDingetjes = "~1.1.4"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
PlotlyBase = "~0.8.18"
PlutoUI = "~0.7.37"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "85b5da0fa43588c75bb1ff986493443f821c70b7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "180d744848ba316a3d0fdf4dbd34b77c7242963a"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.18"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "bf0a1121af131d9974241ba53f601211e9303a9e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.37"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═7b8a4360-aaa4-11ec-2efc-b1778f6d3a8c
# ╠═810fb486-10b5-460f-a25a-1a7c9d84e256
# ╠═676d318f-b4a4-4949-a5db-1c3a5fd9fa68
# ╠═fc52e423-1370-4ca9-95dc-090815278a4a
# ╠═7bd46437-8af0-4a15-87e9-1508869e1600
# ╠═4a18fa5d-7c73-468b-bed2-3acff51e3981
# ╠═0ae3f943-4f9b-4cfb-aa76-3bcdc7dc9963
# ╠═90fd960f-65b3-4d8c-b8a8-42d3be8c770f
# ╠═e9d43bc6-390e-43c3-becb-d1584202da41
# ╟─16f4b455-086b-4a8b-8767-26fb00a77aad
# ╠═03bf1bc5-37a9-4b02-bff7-f8b42500c4fc
# ╟─c3dcd4d9-5e57-4189-a7f8-524afd6db1e6
# ╠═214cae09-fb98-4ca8-8475-62563e31f665
# ╠═6a4a5cc2-dca5-4f5d-a7e2-9b1f2fbaa406
# ╠═441b20b3-ef9a-4d8a-a6b0-6b6be151a3dd
# ╠═271fd3a7-8347-407d-92d0-2d49758cb3f1
# ╠═6da3c910-a350-4a7e-b481-88942c97686b
# ╠═1686debe-6d74-4ec5-bf25-12346c8045c2
# ╠═fdc22972-b8aa-4202-bb4e-bfff92574814
# ╟─907d51fd-9aaf-43d0-a83b-879cae330a0b
# ╠═10da78b9-9a67-4cd8-9453-c01ea4baabeb
# ╠═ea88edae-c1a1-4cd3-95da-fd6d5cf337ff
# ╠═5e5cf476-609c-4669-bf5d-c3fc3b75b2fe
# ╠═0c84069c-8362-43e7-8f0f-10f445ddc7fd
# ╟─83f2fe95-a6c2-42ec-ac86-72a4b4ec95c3
# ╠═4b1688b2-677e-41be-9446-e395925a7311
# ╠═49cf85b1-bf09-49de-8468-4e240dc621fa
# ╠═997f1421-b2f7-40c2-bc5b-f8a21cb4b04a
# ╟─e6b52b32-def4-4d71-80ca-e43530b1e704
# ╟─77fe2c5d-f3dd-4779-92a4-e0ceadb639a9
# ╠═2380a265-700d-4fed-a52e-f6fa1ce41391
# ╠═bc727ded-8675-420d-806e-0b49357118e5
# ╠═f9c0a331-1f1c-4648-9c24-5e9e16d6be18
# ╠═b0d77b4f-da8f-4a0b-a244-043b2e3bdfae
# ╠═64ce91b4-aaa3-45ec-b4d6-f24457167667
# ╠═b8e1b177-6686-4b58-8c4c-991d9c148520
# ╟─4e296bdd-cbd4-4d43-a769-0b4a80d7dec9
# ╠═628c6e1f-03eb-43a2-8092-a2f61cf6bcbd
# ╠═ebcc9c42-9928-4a20-a307-02ee6ef726d0
# ╟─fa975cb6-4ec1-419a-bcd6-527c0762a533
# ╟─8b57581f-65b3-4edf-abe3-9dfa4ed82ed5
# ╠═f5491a94-5ea8-4459-b6ee-5d37f2ba6188
# ╠═92f5a728-6c57-47b7-9929-e2e19f91da2f
# ╟─656e982b-d805-4a75-b3e6-53a4444e5374
# ╠═0f088a21-7d5f-43f7-b99f-688338b61dc6
# ╟─4ebd0ae4-9f4f-42b2-980e-a25550d01b6b
# ╠═de2a547b-3ccd-4f56-96c0-81a7d9b2d272
# ╠═35e643ab-e3ea-427b-85f2-685b6b6103b8
# ╠═3cc48426-1c39-4afe-bf3e-7f4aa2197fca
# ╠═67137f84-a284-4615-b7a8-729f0a412939
# ╠═83906aab-d4ac-4c2b-b7a4-718edb0c2a18
# ╟─0215aea2-eb79-449e-8dee-a32ca3c5d5f9
# ╠═4c6a1004-52ca-40c1-915a-081c0a3c5fbf
# ╟─87af8c6f-3d6d-44c6-87bb-588e01829339
# ╠═50077612-a858-48a0-a187-a9de1489f34f
# ╠═49fe75d5-844d-46d5-a251-7023706a7f92
# ╠═73290c37-481a-4f7d-a92d-038766702890
# ╠═c3fcc72a-389c-456a-aba5-cbfb4a798c9e
# ╠═f6a63433-553c-4857-b767-33465eb22934
# ╠═18e74f8f-39b6-4c8f-a06f-214d4e9dc6fb
# ╟─8a047414-cd5d-4491-a143-eb30578928ce
# ╠═f9d1e69f-7a07-486d-b43a-334c1c77790a
# ╠═d42d4694-e05d-4e0e-a198-79a3a5cb688a
# ╟─acba5003-a456-4c1a-a53f-71a3bec30251
# ╟─0c30855c-6542-4b1a-9427-3a8427e75210
# ╠═8bf75ceb-e4ae-4c6c-8ab0-a81350f19bc7
# ╠═de0cb780-ff4e-4236-89c4-4c3163337cfc
# ╠═dd23fe10-a8d5-461a-85a8-e03468cdcd97
# ╠═ccf62e33-8fcf-45d9-83ed-c7de80800b76
# ╠═1460ece1-7828-4e93-ac37-e979b874b492
# ╠═18c80ea2-0df4-40ea-bd87-f8fee463161e
# ╠═ce29fa1f-0c52-4d38-acbd-0a96cb3b9ce6
# ╟─c3e29c94-941d-4a52-a358-c4ffbfc8cab8
# ╠═b0473b9a-2db5-4d03-8344-b8eaf8428d6c
# ╠═73945da3-af45-41fb-9c5d-6fbba6362256
# ╠═684ef6d7-c1ae-4af3-b1bd-f54bc29d7b53
# ╠═ea9faecf-ecd7-483b-99ad-ede08ba05383
# ╠═f8f7b530-1ded-4ce0-a7d9-a8c92afb95c7
# ╠═c3b1a198-ef19-4a54-9c32-d9ea32a63812
# ╠═e9fc2030-c2f0-48e9-a807-424039e796b2
# ╟─de101f40-27db-43ea-91ed-238502ceaaf7
# ╠═6c709fa0-7a53-4554-ab2a-d8181267ec93
# ╠═671296b9-6743-48d6-9c4d-1beac2b505b5
# ╟─6128ff76-3f1f-4144-bb3d-f44678210013
# ╠═a5823eb2-3aaa-4791-bdc8-196eac2ccf2e
# ╟─aaf0fe61-d5e6-4d93-8a22-7f97f1249b35
# ╠═6e12592d-01fe-455a-a19c-7544258b9791
# ╠═36c4a5b1-03f2-4f5f-b9af-822a8f7c8cdf
# ╠═8b1ab8a6-d2a7-4a15-9690-d83ebaed5c19
# ╟─38a81414-0bcd-4d71-af1d-fe154d2ae09a
# ╠═2dd5534f-ce46-4770-b0f3-6e16005b3a90
# ╠═f69c6955-800c-461e-b464-cab4989913f6
# ╠═bfe5f717-4702-4316-808a-726fefef9e7e
# ╟─cb3f5ee4-5504-4337-8a8d-d45784f54c85
# ╠═e0271a15-08b5-470f-a2d2-6f064cd3a2b2
# ╠═cb1f840f-8d99-4076-9554-7d8ba56e9865
# ╠═22245242-80a6-4a5b-815e-39b469002f84
# ╟─2fa13939-eba2-4d25-b461-56be79fc1db6
# ╟─5a324fba-1033-4dcf-b10c-1fa4f231355c
# ╠═9f2c0123-7e1a-43b7-861a-d059bb28f776
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
