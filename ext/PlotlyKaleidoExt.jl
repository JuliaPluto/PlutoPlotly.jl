module PlotlyKaleidoExt

using PlutoPlotly: PlutoPlot
using PlotlyKaleido: savefig, PlotlyKaleido

PlotlyKaleido.savefig(io::IO, p::PlutoPlot, args...; kwargs...) = savefig(io, p.Plot, args...; kwargs...)

end