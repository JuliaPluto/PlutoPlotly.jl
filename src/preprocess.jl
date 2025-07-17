const FORCE_FLOAT32 = ScopedValue(true)

# Get a val to specify whether 
floatval() = Val{FORCE_FLOAT32[]}()

# Helper struct just to have the name as symbol parameter for dispatch
struct AttrName{S}
    name::Symbol
    AttrName(s::Symbol) = new{s}(s)
end
# This is used to handle args... which in case only one element is passed is not iterable
Base.iterate(n::AttrName, state=1) = state > 1 ? nothing : (n, state + 1)

#=
This function is basically `_json_lower` from PlotlyBase, but we do it directly
on the PlutoPlot to avoid the modifying the behavior of `_json_lower` for `Plot`
objects (which is required to modify how matrices are passed to `publish_to_js`).

We now have a complex dispatch to be able to do custom processing for specific
attributes.

The standard signature for a _process_with_names method is:
    _process_with_names(x, fl::Val, @nospecialize(args::Vararg{AttrName}))

where 
- the first argument should be the actual input to process and should be
typed accordingly for dispatch.
- The second argument is either `Val{true}` or `Val{false}` and represents the
flag to force number to be converted in Float32. # We added this to
significantly improve performance as the runtime check for converting or not was
creating type instability.
- All the remaining arguments are of type `AttrName` and represent the path of
attributes names leading to this specific input. For example, if we are
processing the input that is inside the xaxis_range in the layout, the function
call will have this form:
    _process_with_names(x, fl, AttrName(:xaxis), AttrName(:range), AttrName(:layout))

This again is to allow dispatch to work on the path so that one can customize behavior of _process_with_names with great control.
At the moment this is only used for modifying the behavior when `title` is
passed as a String, changing it to the more recent plotly syntax (see
https://github.com/JuliaPluto/PlutoPlotly.jl/issues/51)

The various `@nospecialize` below are to avoid exploding compilation given our exponential number of dispatch options, so we only specialize where we need.
=#

# Main _process_with_names for the PlutoPlot object
function _process_with_names(pp::PlutoPlot)
    p = pp.Plot
    fl = floatval()
    out = Dict(
        :data => _process_with_names(p.data, fl, AttrName(:data)),
        :layout => _process_with_names(p.layout, fl, AttrName(:layout)),
        :frames => _process_with_names(p.frames, fl, AttrName(:frames)),
        :config => _process_with_names(p.config, fl, AttrName(:config))
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
    out[:layout][:template] = _process_with_names(template, fl, AttrName(:template), AttrName(:layout))
    out
end

# Generic fallbacks
_process_with_names(x, ::Val, @nospecialize(args::Vararg{AttrName})) = _preprocess(x)
_process_with_names(x) = _process_with_names(x, floatval())

# Handle strings
_process_with_names(s::AbstractString, ::Val, @nospecialize(args::Vararg{AttrName})) =
    _preprocess(s)
_process_with_names(s::AbstractString, ::Val, ::AttrName{:title}, @nospecialize(args::Vararg{AttrName})) =
    Dict(:text => _preprocess(s))

# Handle Reals
_process_with_names(x::Real, ::Val{false}, @nospecialize(args::Vararg{AttrName})) = x
_process_with_names(x::Real, ::Val{true}, @nospecialize(args::Vararg{AttrName})) = x isa Bool ? x : Float32(x)
# Tuple, Arrays
_process_with_names(x::Union{Tuple,AbstractArray}, fl::Val, @nospecialize(args::Vararg{AttrName})) = [_process_with_names(el, fl, args...) for el in x]
# Multidimensional array of numbers must be nested 1D arrays
_process_with_names(A::AbstractArray{<:Union{Number,AbstractVector{<:Number}},N}, fl::Val, @nospecialize(args::Vararg{AttrName})) where {N} =
    if N == 1
        [_process_with_names(el, fl, args...) for el in A]
    else
        [_process_with_names(collect(s), fl, args...) for s ∈ eachslice(A; dims=ndims(A))]
    end

# Dict ans HasFields
function _process_with_names(d::Dict, fl::Val, @nospecialize(args::Vararg{AttrName}))
    Dict{Any,Any}(k => if k isa Symbol
        # We have this branch as we might have plotly properties here and we assume
        # they are if the dict key is a symbol.
        _process_with_names(v, fl, AttrName(k), args...)
    else
        _process_with_names(v, fl, args...)
    end for (k, v) in pairs(d))
end
function _process_with_names(d::Dict{Symbol}, fl::Val, @nospecialize(args::Vararg{AttrName}))
    Dict{Symbol,Any}(k => _process_with_names(v, fl, AttrName(k), args...) for (k, v) in pairs(d))
end
# We have a separate one because it seems to reduce allocations
_process_with_names(a::PlotlyBase.HasFields, fl::Val, @nospecialize(args::Vararg{AttrName})) =
    _process_with_names(a.fields, fl, args...)

# Templates
_process_with_names(t::PlotlyBase.Template, fl::Val, @nospecialize(args::Vararg{AttrName})) = Dict(
    :data => _process_with_names(t.data, fl, AttrName(:data), args...),
    :layout => _process_with_names(t.layout, fl, AttrName(:layout), args...)
)

# Config
function _process_with_names(pc::PlotlyBase.PlotConfig, fl::Val, @nospecialize(args::Vararg{AttrName}))
    out = Dict{Symbol,Any}()
    for fn in fieldnames(PlotlyBase.PlotConfig)
        field = getfield(pc, fn)
        if !isnothing(field)
            out[fn] = _process_with_names(field, fl, AttrName(fn), args...)
        end
    end
    out
end

## The functions below are the internal processing only taking the value, so not depending on names path or float32 flag
# Defaults to JSON.lower for generic non-overloaded types
_preprocess(x) = PlotlyBase.JSON.lower(x) # Default
_preprocess(x::TimeType) = sprint(print, x) # For handling datetimes

_preprocess(s::Union{AbstractString,Symbol}) = String(s)

_preprocess(x::Union{Nothing,Missing}) = x
_preprocess(x::Symbol) = string(x)

_preprocess(c::PlotlyBase.Cycler) = c.vals

function _preprocess(c::PlotlyBase.ColorScheme)::Vector{Tuple{Float64,String}}
    N = length(c.colors)
    map(ic -> ((ic[1] - 1) / (N - 1), _preprocess(ic[2])), enumerate(c.colors))
end

# Files that will be later moved to an extension. At the moment it's pointless because PlotlyBase uses those internally anyway.
_preprocess(s::LaTeXString) = s.s

# Colors, they can be put inside an extension
_preprocess(c::Color) = @views begin
    s = hex(c, :rrggbb)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    return "rgb($r,$g,$b)"
end
_preprocess(c::TransparentColor) = @views begin
    s = hex(c, :rrggbbaa)
    r = parse(Int, s[1:2]; base=16)
    g = parse(Int, s[3:4]; base=16)
    b = parse(Int, s[5:6]; base=16)
    a = parse(Int, s[7:8]; base=16)
    return "rgba($r,$g,$b,$(a/255))"
end