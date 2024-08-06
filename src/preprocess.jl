const SKIP_FLOAT32 = Ref(false)
skip_float32(f) =
    let
        SKIP_FLOAT32[] = true
        out = f()
        SKIP_FLOAT32[] = false
        out
    end

#=
This function is basically `_json_lower` from PlotlyBase, but we do it directly
on the PlutoPlot to avoid the modifying the behavior of `_json_lower` for `Plot`
objects (which is required to modify how matrices are passed to `publish_to_js`)
=#

# Main _preprocess for the PlutoPlot object
function _preprocess(pp::PlutoPlot)
    p = pp.Plot
    out = Dict(
        :data => _preprocess(p.data; path=(:data,)),
        :layout => _preprocess(p.layout; path=(:layout,)),
        :frames => _preprocess(p.frames; path=(:frames,)),
        :config => _preprocess(p.config; path=(:config,))
    )

    templates = PlotlyBase.templates
    layout_template = p.layout.template
    template = if layout_template isa String
        layout_template === "none" ? Template() : templates[layout_template]
    elseif layout_template === templates[templates.default]
        # If we enter here we did not specify any template in the layout, so se use our default
        DEFAULT_TEMPLATE[]
    else
        layout_template
    end
    out[:layout][:template] = _preprocess(template; path=(:layout, :template))
    out
end

# Defaults to JSON.lower for generic non-overloaded types
_preprocess(x; path=(:nothing,)) = PlotlyBase.JSON.lower(x) # Default
_preprocess(x::TimeType; path=(:nothing,)) = sprint(print, x) # For handling datetimes

function _preprocess(s::AbstractString; path=(:nothing,))
    s = String(s)
    return last(path) === :title ?
           _preprocess(attr(; text=s); path) : # We make the title in the non-legacy format
           s
end

_preprocess(x::Real; path = (:nothing,)) = SKIP_FLOAT32[] ? x : Float32(x)

_preprocess(x::Union{Bool,Nothing,Missing}; path = (:nothing,)) = x
_preprocess(x::Symbol; path = (:nothing,)) = string(x)
_preprocess(x::Union{Tuple,AbstractArray}; path = (:nothing,)) = _preprocess.(x)
_preprocess(A::AbstractArray{<:Union{Number,AbstractVector{<:Number}},N}; path = (:nothing,)) where {N} =
    if N == 1
        collect(_preprocess.(A); path)
    else
        [_preprocess(collect(s); path) for s ∈ eachslice(A; dims=ndims(A))]
    end
function _preprocess(d::Dict; path = (:nothing,))
    Dict{Any,Any}(k => _preprocess(v; path = (path..., Symbol(k))) for (k, v) in pairs(d))
end
_preprocess(a::PlotlyBase.HasFields; path = (:nothing,)) = Dict{Any,Any}(k => _preprocess(v; path = (path..., Symbol(k))) for (k, v) in pairs(a.fields))
_preprocess(c::PlotlyBase.Cycler; path = (:nothin,)) = c.vals
function _preprocess(c::PlotlyBase.ColorScheme; path = (:nothing,))::Vector{Tuple{Float64,String}}
    N = length(c.colors)
    map(ic -> ((ic[1] - 1) / (N - 1), _preprocess(ic[2])), enumerate(c.colors))
end

_preprocess(t::PlotlyBase.Template; path = (:template,)) = Dict(
    :data => _preprocess(t.data; path = (path..., :data)),
    :layout => _preprocess(t.layout; path = (path..., :layout))
)

function _preprocess(pc::PlotlyBase.PlotConfig; path = (:config,))
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
_preprocess(s::LaTeXString; path = (:nothing,)) = s.s

# Colors, they can be put inside an extension
_preprocess(c::Color; path = (:nothing,)) = @views begin
    s = hex(c, :rrggbb)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    return "rgb($r,$g,$b)"
end
_preprocess(c::TransparentColor; path = (:nothing,)) = @views begin
    s = hex(c, :rrggbbaa)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    a = parse(Int, s[7:8]; base=16)
    return "rgba($r,$g,$b,$(a/255))"
end