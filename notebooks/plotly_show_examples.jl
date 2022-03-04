### A Pluto.jl notebook ###
# v0.18.1

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

# ╔═╡ 48714860-82c3-11ec-39de-4591cdf18398
begin
	using PlutoUI
	using PlotlyBase
	using HypertextLiteral
end

# ╔═╡ f8d86f9e-caa6-4f04-bd4e-d885de9e4aef
TableOfContents()

# ╔═╡ 5737c2b0-eac4-40d5-9838-f140fdc5ad7e
md"""
# Let's plot with PlotlyBase!
"""

# ╔═╡ 8e2d1daa-3e42-453e-be37-f3baa66beddc
md"""
[PlotlyBase.jl](https://github.com/sglyon/PlotlyBase.jl) is a light Julia wrapper for the [plotly](https://plotly.com/javascript/) JS library which is used to provide nice interactive plots on the browser for many other languages!

Usually, one would have to use [PlotlyJS.jl](https://github.com/JuliaPlots/PlotlyJS.jl) package either directly or as a backend of Plots.jl to use plotlyjs in Julia, but it can be done directly with PlotlyBase when working directly in Pluto!

Most of the synthax is shared between PlotlyBase and PlotlyJS so either the the official package documentation at [http://juliaplots.org/PlotlyJS.jl/stable/](http://juliaplots.org/PlotlyJS.jl/stable/) or the officialy plotly julia reference page [https://plotly.com/julia/](https://plotly.com/julia/) can be used for documentation.
"""

# ╔═╡ 522ac06e-7665-47ce-81d7-6d176c1abdfe
md"""
# `Plot` default show method
"""

# ╔═╡ b7b45a09-d25b-49bd-a13d-ccb8874de729
md"""
The basic object for creating plots in PlotlyBase is the `PlotlyBase.Plot` object, which unfortunately shows quite poorly by default inside a Pluto notebook.
As you can see below, the figure is usually super short with all the y axis compressed.
"""

# ╔═╡ ee198566-c2db-4dad-9c02-6674cdee675b
Plot(rand(10,4))

# ╔═╡ 19f96a28-cd6b-4acb-b98d-cf8271e7454a
md"""
!!! note
	The default show method is overloaded below so if you re-execute the cell above it does not show poorly with the show method set by `PlotlyBase`
"""

# ╔═╡ a786110a-d443-447c-ac0c-64b7e4a6e0cb
md"""
# Custom `show` method
"""

# ╔═╡ ba88c184-e128-44de-9002-32dd30e820da
md"""
## Simplest approach
"""

# ╔═╡ 2ec89066-a28c-45af-83f5-af15759ad394
md"""
An easy way to make the plot look much nicer is to create a custom show method exploiting the amazing `@htl` macro
"""

# ╔═╡ d0a833a0-5b85-430f-896c-981fc92515fe
function show1(plt::Plot)
	@htl """
		<script id="pluto-plotly-div">
		const {plotly} = await import("https://cdn.plot.ly/plotly-2.8.0.min.js")
		const PLOT = this ?? document.createElement("div");
	
		Plotly.react(PLOT, $(HypertextLiteral.JavaScript(PlotlyBase.json(plt))));
	
		return PLOT
		</script>
	"""
end

# ╔═╡ 02d49c00-128f-44c6-831e-40669c3244d2
md"""
Unfortunately the simple show function above has some issues  with Pluto statefulness as plotly plots are *responsive* by default, which causes the window to resize everytime the plot is redrawn even with statefulness.
You can see this by moving the slider below between the two plots.

The upper plot has the responsive flag on, while the lower one doesn't. You see that the first plot only gets correctly rendered once every two reactive runs, or when manually executed.
"""

# ╔═╡ 7a92d1a0-763e-4fcc-860b-8d9f23e8447a
@bind lines Slider(2:5)

# ╔═╡ 9ea6fdbe-57fc-42eb-b649-be249849b198
show1(Plot(rand(10,lines)))

# ╔═╡ 809467d9-39e9-45b2-b583-6640bdbf187f
show1(Plot(rand(10,lines); config = PlotConfig(responsive = false)))

# ╔═╡ a703ec31-7533-4f28-a6a6-845c52402241
md"""
## Responsiveness hack
"""

# ╔═╡ 9e2efad9-98f9-4b0c-afc9-be7b0b5a2130
md"""
To keep the responsiveness we can disable the flag in the plot object but achieve it with JS using a `ResizeObserver`.
"""

# ╔═╡ cda19717-e9df-4dc8-bf05-974dcdaea9c6
function show2(plt::Plot)
	# Disable the plot responsiveness flag
	plt.config.responsive = false
	@htl """
		<script id="pluto-plotly-div">
		const {plotly} = await import("https://cdn.plot.ly/plotly-2.9.0.min.js")
		const PLOT = this ?? document.createElement("div");

		// We transform the Plot object to json to use it directly in javascript
		Plotly.react(PLOT, $(HypertextLiteral.JavaScript(PlotlyBase.json(plt))));

		// Code to simulate the plot responsiveness
		const pluto_output = currentScript.parentElement.closest('pluto-output')

		const resizeObserver = new ResizeObserver(entries => {
			Plotly.Plots.resize(PLOT)
		})

		resizeObserver.observe(pluto_output)

		invalidation.then(() => {
			resizeObserver.disconnect()
		})

		return PLOT
		</script>
	"""
end

# ╔═╡ 1d421347-8323-4a83-bf67-7d6e31ee87b7
md"""
Check below that now the plot is responsive and the state is preserved across reactive runs!\
The horizontal scroll bar disappeared as well from the cells with Plots!
"""

# ╔═╡ 0bb10fe4-bfcd-4494-8f74-6b822220b443
@bind lines2 Slider(2:5)

# ╔═╡ e9855163-58a3-401e-8c57-37b25e64e3d0
show2(Plot(rand(10,lines2)))

# ╔═╡ 4907ee38-cc16-4fa6-825d-4be05a793f55
md"""
## Using `publish_to_js`
"""

# ╔═╡ 235bb3df-3b2c-45b5-b177-544e565ba321
md"""
The approach above works quite well but still sends the full plot data as a JSON string. When the amount of data is significant this might be slower so it is beneficial to exploit the `PlutoRunner.publish_to_js` function!

Since `publish_to_js` only supports a subset of basic types, we have to transform all the Plot data into a Dict of `Packable` types.
The non-exported function `PlotlyBase._json_lower` almost does all the work for us, but does not modify multi-dimensional arrays. These are not compatible with JS but the `JSON.json` function takes care of transforming matrices into vectors of vectors.

To make sure matrices are directly transformed into vectors of vectors in the dict, we must add a method to `PlotlyBase._json_lower`:
"""

# ╔═╡ b36fbb26-ff11-4295-8e91-1b1703f6284d
# Override the default methods so  matrices are decomposed in vectors of vectors. I don't think higher dimension arrays are relevant for plotting so we just stick to Matrix
PlotlyBase._json_lower(m::Matrix{<:Number}) = [collect(c) for c ∈ eachcol(m)]

# ╔═╡ a40944b5-d8e4-46fe-a436-b002aa9a42a5
md"""
We also have to give a warning in case this is not run within pluto
"""

# ╔═╡ d96e7a58-25d1-4408-8ff4-daa96141be48
publish_to_js = if (isdefined(Main, :PlutoRunner) && Main.PlutoRunner isa Module)
	PlutoRunner.publish_to_js
else
	@warn "You loaded this package outside of Pluto, this is not the intended behavior and you should use either PlotlyBase or PlotlyJS directly"
	x -> x
end

# ╔═╡ 38c16f4e-d9b5-48da-a173-2e7f5ecd3da1
function show3(plt::Plot, script_id = "pluto-plotly-div")
	# Disable the plot responsiveness flag
	plt.config.responsive = false
	@htl """
		<script id=$(script_id)>
		const {plotly} = await import("https://cdn.plot.ly/plotly-2.9.0.min.js")
		const PLOT = this ?? document.createElement("div");

		let plot_obj = $(publish_to_js(PlotlyBase._json_lower(plt)))
	
		Plotly.react(PLOT, plot_obj);

		// Code to simulate the plot responsiveness
		const pluto_output = currentScript.parentElement.closest('pluto-output')

		const resizeObserver = new ResizeObserver(entries => {
			Plotly.Plots.resize(PLOT)
		})

		resizeObserver.observe(pluto_output)

		invalidation.then(() => {
			resizeObserver.disconnect()
		})

		return PLOT
		</script>
	"""
end

# ╔═╡ 0f7ea8d6-4cc7-429b-b1c2-68c0c4d64d2f
@bind lines3 Slider(2:5)

# ╔═╡ 2f6084be-c25d-474d-8108-6e0c0b79149f
p3 = Plot(rand(10,lines3));

# ╔═╡ beb597d4-fa69-4171-9043-7c7bd203d52f
show3(p3)

# ╔═╡ 3fd194fd-f7e4-4beb-893e-d7b696b24b0c
md"""
### Speed comparison
"""

# ╔═╡ 93a81bcb-7858-494c-bbbf-e488a52c6f57
md"""
To appreciate the speed difference between `show2` using JSON and `show3` using `publish_to_js`, try to run the clocks below and see that the `show3` methods is more snappy!
"""

# ╔═╡ e8bf89f5-1e8d-4615-9526-8ad4c21b895b
@bind show2_clock Clock(interval=0.5)

# ╔═╡ 4a15a205-9022-4ce4-8bbd-3f7ccbf8528d
let
	show2_clock
	x = rand(10_000,10)
	Plot(x) |> show2
end

# ╔═╡ e8ddb6d0-a4f0-4e58-a4a7-71c34c620d27
@bind show3_clock Clock(interval=0.5)

# ╔═╡ 80b382c2-b57b-4b34-9805-8e40425d7c53
let
	show3_clock
	x = rand(10_000,10)
	Plot(x) |> show3
end

# ╔═╡ 559a81ae-8b01-4a2b-974d-234510da01e6
md"""
## Make it work with mutiple plot per cell
"""

# ╔═╡ 160dbfec-48b3-49d9-898e-245bc96b12a3
md"""
If multiple plots in the same cell are given a same script name id in JS, reactive runs of the cell will result in only one of the multiple plots being shown.

The functions below are some *hacks* inspired by a comment by *fonsp* about storing some kind of counter inside the IO object passed to show methods.
"""

# ╔═╡ 53d1714c-1dbc-49d1-b46c-2a16182b5f51
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

# ╔═╡ d4104841-2120-4f3c-8234-68542fb214e8
# Using the unique_io_counter inside the show3 method allows to have unique counters for plots within a same cell.
# This does not ensure that the same plot object is always given the same unique script id if the plots are added to the cells with `if...end` blocks.
function plotly_script_id(io::IO)
	counter = unique_io_counter(io, "plotly-plot")
	return "plot_$counter"
end

# ╔═╡ 9b80fc4c-97dc-4e96-81a0-f8592202dd46
md"""
# 3D plot example
"""

# ╔═╡ 1b6c47e5-c543-45d7-9ddb-4b3d557098ad
@bind npts Slider(100:10:200)

# ╔═╡ 9f65dd0d-bdbe-4dc3-81ee-03449d78141c
let
	x = -npts:npts
	y = -npts:npts
	z = [x^2 + y^3 for x ∈ x, y ∈ y]
	surface(;x,y,z) |> Plot |> show3
end

# ╔═╡ 8fa920e7-03e4-4520-a8e6-9b78c9531c31
md"""
# Override default show
"""

# ╔═╡ accdaf27-955e-43db-ba44-82889967a99b
md"""
Overriding the default show method is as easy as executing the function below:
"""

# ╔═╡ 334212d8-9832-4f7b-b793-cf111700d4a6
function Base.show(io::IO, mime::MIME"text/html", plt::Plot)
	show(io, mime, show3(plt, plotly_script_id(io)))
end

# ╔═╡ 38431225-48f6-4a9a-88dc-f991f9845820
@bind lines4 Slider(2:5)

# ╔═╡ bdbd05ae-2022-4cc1-867a-bca5940571bc
Plot(rand(10,lines4))

# ╔═╡ 65ce8a56-b621-4acc-92f9-34e701b14839
md"""
# Multiple plots per cell example
"""

# ╔═╡ 8860d602-7c3c-4a60-a4cd-6d56ca79f571
asdasd = 2

# ╔═╡ 7ff3ae77-2145-46c4-b813-fd74f8476622
flag = true

# ╔═╡ 34b22e05-bc0d-4be0-a599-480aaf72000f
let
	asdasd
	@htl """
	<div>
		
		$(Plot(rand(10,4)))
	$((flag ? Plot(rand(10,3)) : nothing))
		$(Plot(rand(10,2)))
	</div>
	"""
end

# ╔═╡ 9079664c-cf22-4baa-8bfb-a04db862e0f6
md"""
# Issues
"""

# ╔═╡ d051c233-d589-4445-89b0-6bd129e3c92e
md"""
## Forcing `responsive` to false
"""

# ╔═╡ f658cbf9-2ec1-486d-9798-b653b897bcbe
md"""
The current hack to avoid the plot window disappearing 1 responsive run out of 2 is to use a `ResizeObserver` and force the `Plot` responsive flag to false.

Having the plot work without this hack would be nicer, especially considering that plotly.js does not seem to plan on keeping this flag in the future based on the [docstring](https://github.com/plotly/plotly.js/blob/3aa9559bed73a04f9d5b5c9f5017cc1034953495/src/plot_api/plot_config.js#L121)
"""

# ╔═╡ e92ceb10-f490-4fa8-bfc8-f97341ba8c91
md"""
## Plots inside flexbox
"""

# ╔═╡ 50660f2b-cf61-45de-a0a8-6abb05c297dc
md"""
Plots inside flexbox divs do not autosize (at least in width) to adapt to the flexbox parent. 

See [this codepen](https://codepen.io/disberd/pen/abVLPpW) for some experiments with plotly inside flexbox divs.
"""

# ╔═╡ e067d5b1-4829-4935-8d2c-3c058a3a73bd
@htl """
	<div class='flexdiv'>
		$(Plot(rand(10,4)) |> show3)
		$(Plot(rand(10,4)) |> show3)
	</div>
"""

# ╔═╡ d9a00db0-ecd7-45ac-bebd-e7f2f0b48418
@htl """
<style>
	.flexdiv {
		display: flex;
  		flex-direction: row;
		height: 500px;
		width: 700px;
	}

	.js-plotly-plot {
	  background: tomato;
	  flex-grow: 1;
	  flex-shrink: 1;
	  //margin-bottom: 10px;
	  margin-right:10px;
	 }
</style>
"""

# ╔═╡ 2fa1464a-9c1c-4fdd-8714-c22c253b342d
#=╠═╡ notebook_exclusive
let
	a = 3
end;
  ╠═╡ notebook_exclusive =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.3"
PlotlyBase = "~0.8.18"
PlutoUI = "~0.7.32"
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
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

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
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

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
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

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
# ╠═48714860-82c3-11ec-39de-4591cdf18398
# ╠═f8d86f9e-caa6-4f04-bd4e-d885de9e4aef
# ╟─5737c2b0-eac4-40d5-9838-f140fdc5ad7e
# ╟─8e2d1daa-3e42-453e-be37-f3baa66beddc
# ╟─522ac06e-7665-47ce-81d7-6d176c1abdfe
# ╟─b7b45a09-d25b-49bd-a13d-ccb8874de729
# ╠═ee198566-c2db-4dad-9c02-6674cdee675b
# ╟─19f96a28-cd6b-4acb-b98d-cf8271e7454a
# ╟─a786110a-d443-447c-ac0c-64b7e4a6e0cb
# ╟─ba88c184-e128-44de-9002-32dd30e820da
# ╟─2ec89066-a28c-45af-83f5-af15759ad394
# ╠═d0a833a0-5b85-430f-896c-981fc92515fe
# ╠═02d49c00-128f-44c6-831e-40669c3244d2
# ╠═9ea6fdbe-57fc-42eb-b649-be249849b198
# ╠═7a92d1a0-763e-4fcc-860b-8d9f23e8447a
# ╠═809467d9-39e9-45b2-b583-6640bdbf187f
# ╟─a703ec31-7533-4f28-a6a6-845c52402241
# ╟─9e2efad9-98f9-4b0c-afc9-be7b0b5a2130
# ╠═cda19717-e9df-4dc8-bf05-974dcdaea9c6
# ╟─1d421347-8323-4a83-bf67-7d6e31ee87b7
# ╠═0bb10fe4-bfcd-4494-8f74-6b822220b443
# ╠═e9855163-58a3-401e-8c57-37b25e64e3d0
# ╟─4907ee38-cc16-4fa6-825d-4be05a793f55
# ╟─235bb3df-3b2c-45b5-b177-544e565ba321
# ╠═b36fbb26-ff11-4295-8e91-1b1703f6284d
# ╟─a40944b5-d8e4-46fe-a436-b002aa9a42a5
# ╠═d96e7a58-25d1-4408-8ff4-daa96141be48
# ╠═38c16f4e-d9b5-48da-a173-2e7f5ecd3da1
# ╠═2f6084be-c25d-474d-8108-6e0c0b79149f
# ╠═0f7ea8d6-4cc7-429b-b1c2-68c0c4d64d2f
# ╠═beb597d4-fa69-4171-9043-7c7bd203d52f
# ╟─3fd194fd-f7e4-4beb-893e-d7b696b24b0c
# ╟─93a81bcb-7858-494c-bbbf-e488a52c6f57
# ╠═e8bf89f5-1e8d-4615-9526-8ad4c21b895b
# ╠═4a15a205-9022-4ce4-8bbd-3f7ccbf8528d
# ╠═e8ddb6d0-a4f0-4e58-a4a7-71c34c620d27
# ╠═80b382c2-b57b-4b34-9805-8e40425d7c53
# ╟─559a81ae-8b01-4a2b-974d-234510da01e6
# ╟─160dbfec-48b3-49d9-898e-245bc96b12a3
# ╠═53d1714c-1dbc-49d1-b46c-2a16182b5f51
# ╠═d4104841-2120-4f3c-8234-68542fb214e8
# ╟─9b80fc4c-97dc-4e96-81a0-f8592202dd46
# ╠═1b6c47e5-c543-45d7-9ddb-4b3d557098ad
# ╠═9f65dd0d-bdbe-4dc3-81ee-03449d78141c
# ╟─8fa920e7-03e4-4520-a8e6-9b78c9531c31
# ╟─accdaf27-955e-43db-ba44-82889967a99b
# ╠═334212d8-9832-4f7b-b793-cf111700d4a6
# ╠═38431225-48f6-4a9a-88dc-f991f9845820
# ╠═bdbd05ae-2022-4cc1-867a-bca5940571bc
# ╟─65ce8a56-b621-4acc-92f9-34e701b14839
# ╠═8860d602-7c3c-4a60-a4cd-6d56ca79f571
# ╠═7ff3ae77-2145-46c4-b813-fd74f8476622
# ╠═34b22e05-bc0d-4be0-a599-480aaf72000f
# ╟─9079664c-cf22-4baa-8bfb-a04db862e0f6
# ╟─d051c233-d589-4445-89b0-6bd129e3c92e
# ╟─f658cbf9-2ec1-486d-9798-b653b897bcbe
# ╟─e92ceb10-f490-4fa8-bfc8-f97341ba8c91
# ╠═50660f2b-cf61-45de-a0a8-6abb05c297dc
# ╠═e067d5b1-4829-4935-8d2c-3c058a3a73bd
# ╠═d9a00db0-ecd7-45ac-bebd-e7f2f0b48418
# ╟─2fa1464a-9c1c-4fdd-8714-c22c253b342d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
