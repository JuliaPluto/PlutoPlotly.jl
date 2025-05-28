function _show(pp::PlutoPlot; script_id = "pluto-plotly-div", ver = get_plotly_version())
@htl """
	<script id=$(script_id)>
        // We add lodash as an import (currently this makes PlutoPlotly not work offline, to be fixed in a next release)
        const _ = await import('https://cdn.jsdelivr.net/npm/lodash-es@4.17.21/+esm')

		// We start by putting all the variable interpolation here at the beginning
		// We have to convert all typedarrays in the layout to normal arrays. See Issue #25
		// We use lodash for this for compactness
		function removeTypedArray(o) {
			return _.isTypedArray(o) ? Array.from(o) :
			_.isPlainObject(o) ? _.mapValues(o, removeTypedArray) : 
			o
		}

		// Publish the plot object to JS
		let plot_obj = _.update($(maybe_publish_to_js(_process_with_names(pp))), "layout", removeTypedArray)
		// Get the plotly listeners
		const plotly_listeners = $(pp.plotly_listeners)
		// Get the JS listeners
		const js_listeners = $(pp.js_listeners)
		// Deal with eventual custom classes
		let custom_classlist = $(pp.classList)


		// Load the plotly library
		const Plotly = $(get_plotly_import(ver, "hybrid"))

		// Check if we have to force local mathjax font cache
		if ($(force_pluto_mathjax_local()) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}

		$(pp.script_contents)

		return CONTAINER
	</script>
"""
end

# ╔═╡ d42d4694-e05d-4e0e-a198-79a3a5cb688a
function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, _show(plt; script_id =  plotly_script_id(io)))
	# show(io, mime, _show(plt))
end