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

# ╔═╡ e9d43bc6-390e-43c3-becb-d1584202da41
# This is only used to simplify debugging (by setting this to false) the plotly internal functions using the developer console
const LOAD_MINIFIED = Ref(true)

# ╔═╡ fa975cb6-4ec1-419a-bcd6-527c0762a533
md"""
# Plot Wrapper
"""

# ╔═╡ 8b57581f-65b3-4edf-abe3-9dfa4ed82ed5
md"""
We define a wrapper around the PlotlyBase.Plot object
"""

# ╔═╡ 0f088a21-7d5f-43f7-b99f-688338b61dc6
begin
	const JS = HypertextLiteral.JavaScript
Base.@kwdef struct PlutoPlot
	Plot::PlotlyBase.Plot
	plotly_listeners::Dict{String, Vector{JS}} = Dict{String, Vector{JS}}()
end
PlutoPlot(p::PlotlyBase.Plot; kwargs...) = PlutoPlot(;kwargs..., Plot = p)
end

# ╔═╡ 90fd960f-65b3-4d8c-b8a8-42d3be8c770f
function Base.show(io::IO, mime::MIME"text/html", s::HypertextLiteral.JavaScript)
if is_inside_pluto()
	show(io, mime, Markdown.MD(Markdown.Code("js",s.content)))
else
	show(io, MIME"text/plain",s)
end
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

See also: [`htl_js`](@ref)

# Examples:
```julia
p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
add_plotly_listener!(p, "plotly_relayout", htl_js(\"\"\"
function(e) {

console.log('listener 1')

}
\"\"\"
```
"""
function add_plotly_listener!(p::PlutoPlot, event_name::String, listener::JS)
	ldict = p.plotly_listeners
	listeners_array = get!(ldict, event_name, JS[])
	push!(listeners_array, listener)
end

# ╔═╡ 35e643ab-e3ea-427b-85f2-685b6b6103b8
add_plotly_listener!(p::PlutoPlot, event_name, listener::String) = add_plotly_listener!(p, event_name, hlt_js(listener))

# ╔═╡ 8a047414-cd5d-4491-a143-eb30578928ce
md"""
# Show Method
"""

# ╔═╡ a46aa0fc-df08-4567-b8f2-9ee923bb486d
# We need to do this in the Pluto notebook because the cell re-ordering puts the `show` method overload at the bottom of the notebook, after the first call to `@htl`, creating a method of `HypertextLiteral.content` (https://github.dev/JuliaPluto/HypertextLiteral.jl/blob/7bbabcc99f77725946af7eddfb9d0c746b70f8f4/src/convert.jl#L87-L100) that creates problem when showing nested `@htl` calls.
HypertextLiteral.content(p::PlutoPlot) = HypertextLiteral.Render(p)

# ╔═╡ acba5003-a456-4c1a-a53f-71a3bec30251
md"""
## Tests
"""

# ╔═╡ dd23fe10-a8d5-461a-85a8-e03468cdcd97
N = 10

# ╔═╡ 8bf75ceb-e4ae-4c6c-8ab0-a81350f19bc7
pp = Plot(scatter3d(x = rand(N), y = rand(N), z = rand(N), mode="markers"), Layout(
	uirevision = 1,
	scene = attr(
		xaxis_range = [-1,2],
		yaxis_range = [-1,2],
		zaxis_range = [-1,2],
		aspectmode = "cube",
	),
	# height = 350
	# autosize = true,
));

# ╔═╡ 18c80ea2-0df4-40ea-bd87-f8fee463161e
@bind asdasd let
	p = PlutoPlot(Plot(rand(10)))
	add_plotly_listener!(p,"plotly_click", htl_js("""
	(e) => {
    
    let dt = e.points[0]
	PLOT.value = [dt.x, dt.y]
	PLOT.dispatchEvent(new CustomEvent("input"))
}
	"""))
	p
end

# ╔═╡ ce29fa1f-0c52-4d38-acbd-0a96cb3b9ce6
asdasd

# ╔═╡ f12362b8-af8d-4bfa-8671-68d184ef7e50
dio = 1

# ╔═╡ c3b1a198-ef19-4a54-9c32-d9ea32a63812
let
	dio
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
	dio
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

# ╔═╡ a5823eb2-3aaa-4791-bdc8-196eac2ccf2e
@htl """
<div style='height: 400px; display: flex'>
$(Plot(rand(10)) |> PlutoPlot)

$(Plot(rand(10)) |> PlutoPlot)
</div>
<script>
window.dispatchEvent(new Event('resize'))
</script>
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
<script>
window.dispatchEvent(new Event('resize'))
</script>
<style>
	.js-plotly-plot {
		flex-grow: 1;
		flex-shrink: 1;
	}
</style>
"""

# ╔═╡ 16f4b455-086b-4a8b-8767-26fb00a77aad
md"""
# Utility Functions
"""

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

# ╔═╡ b8e1b177-6686-4b58-8c4c-991d9c148520
# Escape latexstrings
_preprocess(s::LaTeXString) = s.s

# ╔═╡ f9d1e69f-7a07-486d-b43a-334c1c77790a
function _show(pp::PlutoPlot, script_id = "pluto-plotly-div")
ver = htl_js(PLOTLY_VERSION[])
suffix = htl_js(LOAD_MINIFIED[] ? "min.js" : "js")
@htl """
	<script id=$(script_id)>
		// Load the plotly library
		if (!window.Plotly) {
			const {plotly} = await import('https://cdn.plot.ly/plotly-$(ver).$(suffix)')
		}

		// Check if we have to force local mathjax font cache
		if ($(FORCE_MATHJAX_LOCAL[]) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}

		// Flag to check if this cell was  manually ran or reactively ran
		const firstRun = this ? false : true
		const PLOT = this ?? document.createElement("div");
		const parent = currentScript.parentElement
		const isPlutoWrapper = parent.classList.contains('raw-html-wrapper')

		// Publish the plot object to JS
		let plot_obj = $(publish_to_js(_preprocess(pp)))

		if (firstRun) {
			// It seem plot divs would not autosize themself inside flexbox containers without this
  			parent.appendChild(PLOT)
		}

		// Get the listeners
		const plotly_listeners = $(pp.plotly_listeners)

		// If width is not specified, set it to 100%
		PLOT.style.width = plot_obj.layout.width ? "" : "100%"
		
		// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
		PLOT.style.height = plot_obj.layout.height ? "" :
			(isPlutoWrapper || parent.clientHeight == 0) ? "400px" : "100%"
	
		Plotly.react(PLOT, plot_obj).then(() => {
			// Assign the Plotly event listeners
			for (const [key, listener_vec] of Object.entries(plotly_listeners)) {
				for (const listener of listener_vec) {
				    PLOT.on(key, listener)
				}
			}
		}
		)

		invalidation.then(() => {
			// Remove all listeners
			PLOT.removeAllListeners()
		})

		return PLOT
	</script>
"""
end

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

# ╔═╡ d42d4694-e05d-4e0e-a198-79a3a5cb688a
function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, _show(plt, plotly_script_id(io)))
	# show(io, mime, _show(plt))
end

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
# ╠═e9d43bc6-390e-43c3-becb-d1584202da41
# ╟─fa975cb6-4ec1-419a-bcd6-527c0762a533
# ╟─8b57581f-65b3-4edf-abe3-9dfa4ed82ed5
# ╠═0f088a21-7d5f-43f7-b99f-688338b61dc6
# ╠═90fd960f-65b3-4d8c-b8a8-42d3be8c770f
# ╠═4ebd0ae4-9f4f-42b2-980e-a25550d01b6b
# ╠═de2a547b-3ccd-4f56-96c0-81a7d9b2d272
# ╠═35e643ab-e3ea-427b-85f2-685b6b6103b8
# ╟─8a047414-cd5d-4491-a143-eb30578928ce
# ╠═f9d1e69f-7a07-486d-b43a-334c1c77790a
# ╠═d42d4694-e05d-4e0e-a198-79a3a5cb688a
# ╠═a46aa0fc-df08-4567-b8f2-9ee923bb486d
# ╟─acba5003-a456-4c1a-a53f-71a3bec30251
# ╠═dd23fe10-a8d5-461a-85a8-e03468cdcd97
# ╠═8bf75ceb-e4ae-4c6c-8ab0-a81350f19bc7
# ╠═ccf62e33-8fcf-45d9-83ed-c7de80800b76
# ╠═18c80ea2-0df4-40ea-bd87-f8fee463161e
# ╠═ce29fa1f-0c52-4d38-acbd-0a96cb3b9ce6
# ╠═f12362b8-af8d-4bfa-8671-68d184ef7e50
# ╠═c3b1a198-ef19-4a54-9c32-d9ea32a63812
# ╠═e9fc2030-c2f0-48e9-a807-424039e796b2
# ╠═a5823eb2-3aaa-4791-bdc8-196eac2ccf2e
# ╠═6e12592d-01fe-455a-a19c-7544258b9791
# ╠═36c4a5b1-03f2-4f5f-b9af-822a8f7c8cdf
# ╠═8b1ab8a6-d2a7-4a15-9690-d83ebaed5c19
# ╟─16f4b455-086b-4a8b-8767-26fb00a77aad
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
