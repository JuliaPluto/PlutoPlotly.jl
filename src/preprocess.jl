#=
This function is basically `_json_lower` from PlotlyBase, but we do it directly
on the PlutoPlot to avoid the modifying the behavior of `_json_lower` for `Plot`
objects (which is required to modify how matrices are passed to `publish_to_js`)
=# 

# Main _preprocess for the PlutoPlot object
function _preprocess(pp::PlutoPlot)
	p = pp.Plot
    out = Dict(
        :data => _preprocess(p.data),
        :layout => _preprocess(p.layout),
        :frames => _preprocess(p.frames),
        :config => _preprocess(p.config)
    )

    if templates.default !== "none" && PlotlyBase._isempty(get(out[:layout], :template, Dict()))
        out[:layout][:template] = _preprocess(templates[templates.default])
    end
    out
end

# Defaults to JSON.lower for generic non-overloaded types
_preprocess(x) = PlotlyBase.JSON.lower(x) # Default
_preprocess(x::TimeType) = sprint(print, x) # For handling datetimes

_preprocess(x::Union{Bool,String,Number,Nothing,Missing}) = x
_preprocess(x::Symbol) = string(x)
_preprocess(x::Union{Tuple,AbstractArray}) = _preprocess.(x)
_preprocess(A::AbstractArray{<:Number, N}) where N = if N == 1
    collect(A)
else
    [_preprocess(collect(s)) for s ∈ eachslice(A; dims = ndims(A))]
end
_preprocess(d::Dict) = Dict{Any,Any}(k => _preprocess(v) for (k, v) in pairs(d))
_preprocess(a::PlotlyBase.HasFields) = Dict{Any,Any}(k => _preprocess(v) for (k, v) in pairs(a.fields))
_preprocess(c::PlotlyBase.Cycler) = c.vals
function _preprocess(c::PlotlyBase.ColorScheme)::Vector{Tuple{Float64,String}}
    N = length(c.colors)
    map(ic -> ((ic[1] - 1) / (N - 1), _preprocess(ic[2])), enumerate(c.colors))
end

_preprocess(t::PlotlyBase.Template) = Dict(
    :data => _preprocess(t.data),
    :layout => _preprocess(t.layout)
)

function _preprocess(pc::PlotlyBase.PlotConfig)
    out = Dict{Symbol,Any}()
    for fn in fieldnames(PlotlyBase.PlotConfig)
        field = getfield(pc, fn)
        if !isnothing(field)
            out[fn] = field
        end
    end
    out
end

# Files that will be later moved to an extension. At the moment it's pointless because PlotlyBase uses those internally anyway.
_preprocess(s::LaTeXString) = s.s

# Colors, they can be put inside an extension
_preprocess(c::Color) = @views begin
    s = hex(c, :rrggbb)
    r = parse(Int, s[1:2]; base = 16)
    g = parse(Int, s[3:4]; base = 16)
    b = parse(Int, s[5:6]; base = 16)
    return "rgb($r,$g,$b)"
end
_preprocess(c::TransparentColor) = @views begin
    s = hex(c, :rrggbbaa)
    r = parse(Int, s[1:2]; base = 16)
    g = parse(Int, s[3:4]; base = 16)
    b = parse(Int, s[5:6]; base = 16)
    a = parse(Int, s[7:8]; base = 16)
    return "rgba($r,$g,$b,$(a/255))"
end