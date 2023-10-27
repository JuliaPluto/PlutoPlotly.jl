function _show(pp::PlutoPlot; script_id = "pluto-plotly-div", ver = PLOTLY_VERSION[])
@htl """
	<div class='plutoplotly-container'>
	<div class='plutoplotly-clipboard-header hidden'>
		<span class='plot-height'>Height: <span></span>px</span>
		<span class='plot-width'>Width: <span></span>px</span>
		<span class='plot-scale'>Scale: <span contenteditable=true style='padding: 0 5px'>1</span></span>
		<button class='plot-copy'>Copy</button>
	</div>
	<script id=$(script_id)>
		// We start by putting all the variable interpolation here at the beginning
		// We have to convert all typedarrays in the layout to normal arrays. See Issue #25
		// We use lodash for this for compactness
		function removeTypedArray(o) {
			return _.isTypedArray(o) ? Array.from(o) :
			_.isPlainObject(o) ? _.mapValues(o, removeTypedArray) : 
			o
		}

		// Publish the plot object to JS
		let plot_obj = _.update($(maybe_publish_to_js(_preprocess(pp))), "layout", removeTypedArray)
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

		// Check if we have to force local mathjax font cache
		if ($(force_pluto_mathjax_local()) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}

		$(pp.script_contents)

		return PLOT
	</script>
	</div>
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
"""
end

# ╔═╡ d42d4694-e05d-4e0e-a198-79a3a5cb688a
function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, _show(plt; script_id =  plotly_script_id(io)))
	# show(io, mime, _show(plt))
end