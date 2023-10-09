## add listeners ##
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
end
add_js_listener!(p::PlutoPlot, event_name, listener::String) = 
add_js_listener!(p, event_name, JS(listener))

## add class ##
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

## remove class ##

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

## Push Script ##
"""
	push_script!(p::PlutoPlot, item)
	push_script!(p::PlutoPlot, name::String, item)
Add `item` to the end of the `script_contents` field of the `PlutoPlot` object
`p`. The function accepts a custom name to identify this script as the
`script_contents` is a Dictionary with String Indices.

If the `name` is not provided, a name of the form `custom_script_N` will be
generated automatically.
"""
function push_script!(p::PlutoPlot, name::String, item)
	@nospecialize
	insert!(p.script_contents, name, PrintToScript(item))
	return p
end
function push_script!(p::PlutoPlot, item)
	sc = p.script_contents
	N = count(startswith("custom_script_"), sc.indices) + 1
	name = "custom_script_$N"
	push_script!(p, name, item)
end


## plotly listener ##
"""
	add_plotly_listener!(p::PlutoPlot, event_name::String, listener::String)

Add a custom *javascript* `listener` (to be provided as `String` or directly as
`HypertextLiteral.JavaScript`) to the `PlutoPlot` object `p`, and associated to
the [plotly event](https://plotly.com/javascript/plotlyjs-events/) specified by
`event_name`.

The listeners are added to the HTML plot div after rendering. The div where the
plot is inserted can be accessed using the variable named `PLOT` inside the
listener code.

# Differences with `add_js_listener!`
This function adds a listener using the plotly internal events via the `on`
function. These events differ from the standard javascript ones and provide data
specific to the plot.

See also: [`add_js_listener!`](@ref), [`htl_js`](@ref)

# Examples:
```julia
p = PlutoPlot(Plot(rand(10), Layout(uirevision = 1)))
add_plotly_listener!(p, "plotly_relayout", \"\"\"
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
end
add_plotly_listener!(p::PlutoPlot, event_name::String, listener::String) =
add_plotly_listener!(p, event_name, JS(listener))