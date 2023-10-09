function plot_script(pp::PlutoPlot; kwargs...)
	gen = (x isa Function ? x(pp; kwargs...) : x for x in pp.script_contents)
	reduce(vcat, gen) |> make_script
end

function PlutoCombineHTL.print_html(io::IO, plt::PlutoPlot; full_html = false, pluto = is_inside_pluto(io), kwargs...)
	script = plot_script(plt; pluto, kwargs...)
	if full_html
		println(io, "<!DOCTYPE html>")
		println(io, "<html>")
		println(io, "<head></head>")
		println(io, "<body>")
	end
	print_html(io, script; pluto, kwargs...)
	if full_html
		println(io, "</body>")
		println(io, "</html>")
	end
end

Base.show(io::IO, ::MIME"juliavscode/html", plt::PlutoPlot) = 
print_html(io, plt; pluto = false, full_html = true)

function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, plot_script(plt; script_id =  plotly_script_id(io)))
	# show(io, mime, _show(plt))
end

function PlutoCombineHTL.print_javascript(io::IO, pts::PrintToScript{<:DisplayLocation, PlutoPlot}; pluto = is_inside_pluto(io))
	# Extract the PlutoPlot
	pp = pts.el
	_publish = x -> print_javascript(io, x; pluto)
	_publish_listeners = x -> HypertextLiteral.print_script(io, x)
	# We publish the plot obj
	print(io, "
	// Publish the plot object to JS
	let plot_obj = ")
	_publish(_preprocess(pp))
	# We publish the listeners
	## Plotly
	print(io, "
	// Publish the plotly listeners
	const plotly_listeners = ")
	_publish_listeners(pp.plotly_listeners)
	## JS
	print(io, "
	// Publish the JS listeners
	const js_listeners = ")
	_publish_listeners(pp.js_listeners)
	# Custom classes
	print(io, "
	// Deal with eventual custom classes
	const custom_classlist = ")
	_publish(pp.classList)
	println(io)
end

#= Fix for Julia 1.10 
The `@generated` `print_script` from HypertextLiteral is broken in 1.10
See [issue 33](https://github.com/JuliaPluto/HypertextLiteral.jl/issues/33)
=#
HypertextLiteral.print_script(io::IO, p::Display._PublishToJS) = show(io, MIME"text/javascript"(), p)
HypertextLiteral.print_script(io::IO, p::PlutoPlot) = show(io, MIME"text/javascript"(), p)