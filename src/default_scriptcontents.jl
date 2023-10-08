# This will simply load the plutoplot data in javascript
set!(_default_script_contents, "publish_to_js", (pp::PlutoPlot; kwargs...) -> let
    pts = PrintToScript(pp)
    sc = ScriptContent("""
	// We have to convert all typedarrays in the layout to normal arrays. See Issue #25
	// We use lodash for this for compactness
	function removeTypedArray(o) {
		return _.isTypedArray(o) ? Array.from(o) :
		_.isPlainObject(o) ? _.mapValues(o, removeTypedArray) : 
		o
	}

    if (_.has(plot_obj, "layout")) {
	    plot_obj.layout = removeTypedArray(plot_obj.layout)
    }
	""")
	ds = DualScript(sc, sc)   
    [pts, ds]
end)

# Load the plotly library
set!(_default_script_contents, "load plotly library", (pp; ver = PLOTLY_VERSION[], kwargs...) -> let 
	sc = ScriptContent("""
		// Load the plotly library
		let Plotly = undefined
		try {
			let _mod = await import('$(get_plotly_src("$ver", "local"))')
			Plotly = _mod.default
		} catch (e) {
			console.log("Local load failed, trying with the web esm.sh version")
			let _mod = await import('$(get_plotly_src("$ver", "esm"))')
			Plotly = _mod.default
		}
	""")
	# We don't need a DualScript here as we have the same on both and we don't
	# need to eventually load pluto compat.
	PrintToScript(sc)
end)

# Assign Script id
set!(_default_script_contents, "assign script id", (pp; script_id = missing, kwargs...) -> let 
	DualScript(""; id = script_id)
end)

# Force local mathjax (just in Pluto). 
#= 
We make this a function because we want to load the _current_ value of
`force_pluto_mathjax_local` at each run.
=#
set!(_default_script_contents, "force mathjax local", (pp; kwargs...) -> let 
	sc = ScriptContent("""
		// Check if we have to force local mathjax font cache
		if ($(force_pluto_mathjax_local()) && window?.MathJax?.config?.svg?.fontCache === 'global') {
			window.MathJax.config.svg.fontCache = 'local'
		}
	""")
	# This will only go on Pluto
	PlutoScript(sc)
end)

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
	"""); 
	returned_element = "PLOT",
))

# Adjust width/height
set!(_default_script_contents, "adjust widht/height", let
	# We only do this inside of Pluto
	PlutoScript("""
	// If width is not specified, set it to 100%
	PLOT.style.width = plot_obj.layout.width ? "" : "100%"
	
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	PLOT.style.height = plot_obj.layout.height ? "" :
		(isPlutoWrapper || parent.clientHeight == 0) ? "400px" : "100%"
	""")
end)

# classlist
set!(_default_script_contents, "classlist", let
    # This script will be used for iterating the classlists and assigning them
    ds = DualScript(
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
    )
end)

# resizeObserver
set!(_default_script_contents, "resizeObserver", let
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
	""")
end)

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