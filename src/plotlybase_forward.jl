# Methods that do not return the plot object
for fname in (
    :relayout!,
    :restyle!,
    :addtraces!,
    :deletetraces!,
    :movetraces!,
    :purge!,
    :react!,
    :extendtraces!,
    :prependtraces!,
    # Layout shapes 
    :add_hrect!, :add_hline!, :add_vrect!, :add_vline!, :add_shape!,
    :add_layout_image!,
    # generic methods from API
    first.(PlotlyBase._layout_obj_updaters)...,
    first.(PlotlyBase._layout_vector_updaters)...,
)
    @eval PlotlyBase.$fname(p::PlutoPlot, args...; kwargs...) =
    PlotlyBase.$fname(p.Plot, args...; kwargs...) 
end

# Methods that do return the plot object, (we return the PlutoPlot object in this case)
for fname in (
    :update!,
    :add_trace!,
)
    @eval function PlotlyBase.$fname(p::PlutoPlot, args...; kwargs...) 
        PlotlyBase.$fname(p.Plot, args...; kwargs...) 
        p
    end
end

# Methods that return a copy of the plot
# Methods that do return the plot object, (we return the PlutoPlot object in this case)
for fname in (:fork, :restyle, :relayout, :update, :addtraces, :deletetraces,
:movetraces, :redraw, :extendtraces, :prependtraces, :purge, :react)
    @eval function PlotlyBase.$fname(p::PlutoPlot, args...; kwargs...) 
        p = PlotlyBase.$fname(p.Plot, args...; kwargs...) 
        PlutoPlot(p)
    end
end

# Here we put methods from PlotlyJS.jl
make_subplots(;kwargs...) = plot(Layout(Subplots(;kwargs...)))

@doc (@doc Subplots) make_subplots

# Overload of hcat,vcat,hvcat
Base.hcat(ps::PlutoPlot...) = PlutoPlot(hcat(map(x -> x.Plot, ps)...))
Base.vcat(ps::PlutoPlot...) = PlutoPlot(vcat(map(x -> x.Plot, ps)...))
Base.hvcat(rows::Tuple{Vararg{Int}}, ps::PlutoPlot...) = PlutoPlot(hvcat(rows, map(x -> x.Plot, ps)...))