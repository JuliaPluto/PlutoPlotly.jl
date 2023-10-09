maybe_publish_to_js(x) = if is_inside_pluto()
	published_to_js(x)
else
	x
end

current_cell_id()::Base.UUID = if is_inside_pluto()
	Main.PlutoRunner.currently_running_cell_id[]
else
	Base.UUID(zero(UInt128))
end

## Plotly Version ##
function change_plotly_version(ver::String)
	maybe_add_plotly_local(ver)
	PLOTLY_VERSION[] = ver
end

get_plotly_version() = PLOTLY_VERSION[]

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

## Prepend Cell Selector ##
"""
	prepend_cell_selector(selector="")
	prepend_cell_selector(selectors)

Prepends a CSS selector (represented by the argument `selector`) with a selector
of the current pluto-cell (of the form `pluto-cell[id='cell_id']`, where
`cell_id` is the currently running cell).

It can be used to ease creating style sheets (using `@htl` from
HypertextLiteral.jl) with selector that only apply to the cell where they are
executed.

When called with a vector of selectors as input, prepends each selector and
joins them together using `,` as separator.

`prepend_cell_selector("div") = pluto-cell[id='\$cell_id'] div`

`prepend_cell_selector(["div", "span"]) = pluto-cell[id='\$cell_id'] div, pluto-cell[id='\$cell_id'] span`

As example, one can create a plot and force its width to 400px in CSS by using the following snippet:
```julia
@htl \"\"\"
\$(plot(rand(10)))
<style>
	\$(prepend_cell_selector("div.js-plotly-plot")) {
		width: 400px !important;
	}
</style>
\"\"\"
```
"""
prepend_cell_selector(str::AbstractString="")::String = "pluto-cell[id='$(current_cell_id())'] $str" |> strip
prepend_cell_selector(selectors) = join(map(prepend_cell_selector, selectors), ",\n")

const IO_DICT = Ref{Tuple{<:IO, Dict{UInt, Int}}}((IOBuffer(), Dict{UInt, Int}()))
function get_IO_DICT(io::IO)
	old_io = first(IO_DICT[])
	dict = if old_io === io
		last(IO_DICT[])
	else
		d = Dict{UInt, Int}()
		IO_DICT[] = (io, d)
		d
	end
	return dict
end

## Unique Counter ##
function unique_io_counter(io::IO, identifier = "script_id")
	is_inside_pluto(io) || return -1 # We simply return -1 if not inside pluto
	# We extract (or create if not existing) a dictionary that will keep track of instances of the same script name
	dict = get_IO_DICT(io)
	# We use the objectid as the key
	key = objectid(identifier)
	counter = get(dict, key, 0) + 1
	# Update the counter on the dict that is shared within this IOContext
	dict[key] = counter
end

# Using the unique_io_counter inside the show3 method allows to have unique counters for plots within a same cell.
# This does not ensure that the same plot object is always given the same unique script id if the plots are added to the cells with `if...end` blocks.
function plotly_script_id(io::IO)
	counter = unique_io_counter(io, "plotly-plot")
	return "plot_$counter"
end