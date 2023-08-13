function _show(pp::PlutoPlot; script_id = "pluto-plotly-div", ver = PLOTLY_VERSION[], minified = LOAD_MINIFIED[])
plotly_url = let
    name = "plotly.js-dist" * (minified ? "-min" : "")
    "https://esm.sh/$name@$ver" |> htl_js
end
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
        const {default: Plotly} = await import("$plotly_url")

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
	show(io, mime, _show(plt; script_id =  plotly_script_id(io)))
	# show(io, mime, _show(plt))
end