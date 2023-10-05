function _show(pp::PlutoPlot; kwargs...)
	make_script([
		x isa Function ? x(pp; kwargs...) : x for x in pp.script_contents
	])
end

function Base.show(io::IO, mime::MIME"text/html", plt::PlutoPlot)
	show(io, mime, _show(plt; script_id =  plotly_script_id(io)))
	# show(io, mime, _show(plt))
end

function Base.show(io::IO, mime::MIME"text/javascript", plt::PlutoPlot)
	if is_inside_pluto(io)
		show(io, mime, published_to_js(_preprocess(plt)))
	else
		# We use HypertextLiteral to print the Dict out f _preprocess
		HypertextLiteral.print_script(io, _preprocess(plt))
	end
end

#= Fix for Julia 1.10 
The `@generated` `print_script` from HypertextLiteral is broken in 1.10
See [issue 33](https://github.com/JuliaPluto/HypertextLiteral.jl/issues/33)
=#
HypertextLiteral.print_script(io::IO, p::Display._PublishToJS) = show(io, MIME"text/javascript"(), p)
HypertextLiteral.print_script(io::IO, p::PlutoPlot) = show(io, MIME"text/javascript"(), p)