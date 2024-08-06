module PlotlyKaleidoExt

using PlutoPlotly: PlutoPlot, get_plotly_version
using PlotlyKaleido: savefig, PlotlyKaleido, restart, P, is_running

function get_version_in_kaleido()
    is_running() || return nothing
    exec = P.proc.cmd.exec
    flag_idx = findfirst(startswith("https://cdn.plot.ly"), exec)
    isnothing(flag_idx) && return nothing
    url = exec[flag_idx]
    m = match(r"https://cdn.plot.ly/plotly-(\d+\.\d+\.\d+).min.js", url)
    return first(m.captures) |> VersionNumber
end
function ensure_correct_version()
    pkgversion(PlotlyKaleido) >= v"2.2.1" || return # If we can't change version, we just assume it's correct
    current_version = get_plotly_version()
    # We find the flags in the cmd used to start kaleido, if we have a specified
    # version, that appears as a url of the corresponding version on the plotly
    # CDN, see https://github.com/JuliaPlots/PlotlyKaleido.jl/pull/9 for more
    # details
    kaleido_plotly_version = get_version_in_kaleido()
    if isnothing(kaleido_plotly_version) || kaleido_plotly_version != current_version
        @info "(Re)Starting the kaleido process with plotly version $current_version"
        restart(; plotly_version = current_version) # Process it not active, we simply start it with the correct version
        return
    end
end

function PlotlyKaleido.savefig(io::IO, p::PlutoPlot, args...; kwargs...) 
    ensure_correct_version()
    savefig(io, p.Plot, args...; kwargs...)
end

end