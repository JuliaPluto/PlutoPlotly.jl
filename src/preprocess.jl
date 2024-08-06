const SKIP_FLOAT32 = ScopedValue(false)
skip_float32(f) = let
    with(f, SKIP_FLOAT32 => true)
end

#=
This function is basically `_json_lower` from PlotlyBase, but we do it directly
on the PlutoPlot to avoid the modifying the behavior of `_json_lower` for `Plot`
objects (which is required to modify how matrices are passed to `publish_to_js`)
=#

struct AttrName{S}
    name::Symbol
    AttrName(s::Symbol) = new{s}(s)
end
AttrName(s) = AttrName(Symbol(s))
maybewrap(@nospecialize(n::AttrName)) = (n,)
maybewrap(@nospecialize(x)) = x

# Main _preprocess for the PlutoPlot object
function _preprocess(pp::PlutoPlot)
    p = pp.Plot
    out = Dict(
        :data => _preprocess(p.data, AttrName(:data)),
        :layout => _preprocess(p.layout, AttrName(:layout)),
        :frames => _preprocess(p.frames, AttrName(:frames)),
        :config => _preprocess(p.config, AttrName(:config))
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
    out[:layout][:template] = _preprocess(template, AttrName(:template), AttrName(:layout))
    out
end

# Defaults to JSON.lower for generic non-overloaded types
_preprocess(x, @nospecialize(args::Vararg{AttrName})) = PlotlyBase.JSON.lower(x) # Default
_preprocess(x::TimeType, @nospecialize(args::Vararg{AttrName})) = sprint(print, x) # For handling datetimes

_preprocess(s::AbstractString, @nospecialize(args::Vararg{AttrName})) =
    String(s)
_preprocess(s::AbstractString, ::AttrName{:title}, @nospecialize(args::Vararg{AttrName})) =
    Dict(:text => String(s))


_preprocess(x::Real, @nospecialize(args::Vararg{AttrName})) = SKIP_FLOAT32[] ? x : Float32(x)

_preprocess(x::Union{Bool,Nothing,Missing}, @nospecialize(args::Vararg{AttrName})) = x
_preprocess(x::Symbol, @nospecialize(args::Vararg{AttrName})) = string(x)
_preprocess(x::Union{Tuple,AbstractArray}, @nospecialize(args::Vararg{AttrName})) = [_preprocess(el, args...) for el in x]
_preprocess(A::AbstractArray{<:Union{Number,AbstractVector{<:Number}},N}, @nospecialize(args::Vararg{AttrName})) where {N} =
    if N == 1
        [_preprocess(el, args...) for el in A]
    else
        [_preprocess(collect(s, args...)) for s ∈ eachslice(A; dims=ndims(A))]
    end

_preprocess(d::Dict, @nospecialize(args::Vararg{AttrName})) =
    Dict{Any,Any}(k => _preprocess(v, AttrName(k), maybewrap(args)...) for (k, v) in pairs(d))

_preprocess(a::PlotlyBase.HasFields, @nospecialize(args::AttrName)) =
    Dict{Any,Any}(k => _preprocess(v, AttrName(k), maybewrap(args)...) for (k, v) in pairs(a.fields))

_preprocess(c::PlotlyBase.Cycler, @nospecialize(args::Vararg{AttrName})) = c.vals

function _preprocess(c::PlotlyBase.ColorScheme, @nospecialize(args::Vararg{AttrName}))::Vector{Tuple{Float64,String}}
    N = length(c.colors)
    map(ic -> ((ic[1] - 1) / (N - 1), _preprocess(ic[2], args...)), enumerate(c.colors))
end

_preprocess(t::PlotlyBase.Template, @nospecialize(args::Vararg{AttrName})) = Dict(
    :data => _preprocess(t.data, AttrName(:data), args...),
    :layout => _preprocess(t.layout, AttrName(:layout), args...)
)

function _preprocess(pc::PlotlyBase.PlotConfig, @nospecialize(args::Vararg{Symbol}))
    out = Dict{Symbol,Any}()
    for fn in fieldnames(PlotlyBase.PlotConfig)
        field = getfield(pc, fn)
        if !isnothing(field)
            out[fn] = _preprocess(field, AttrName(fn), args...)
        end
    end
    out
end

# Files that will be later moved to an extension. At the moment it's pointless because PlotlyBase uses those internally anyway.
_preprocess(s::LaTeXString, @nospecialize(args::Vararg{AttrName})) = s.s

# Colors, they can be put inside an extension
_preprocess(c::Color, @nospecialize(args::Vararg{AttrName})) = @views begin
    s = hex(c, :rrggbb)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    return "rgb($r,$g,$b)"
end
_preprocess(c::TransparentColor, @nospecialize(args::Vararg{AttrName})) = @views begin
    s = hex(c, :rrggbbaa)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    a = parse(Int, s[7:8]; base=16)
    return "rgba($r,$g,$b,$(a/255))"
end