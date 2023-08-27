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
    :add_layout_image!
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