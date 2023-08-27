# This hack is necessary to force loading mathjax

const FORCE_MATHJAX_LOCAL = Ref(false)

"""
	force_pluto_mathjax_local::Bool
	force_pluto_mathjax_local(flag::Bool)::Bool

Returns `true` if the `PlutoPlot` `show` method forces svgs produced by MathJax
to be locally cached and `false` otherwise.

The flag can be set at package level by providing the intended boolean value as
argument to the function

Local svg caching is used to make mathjax in recent plolty versions (>2.10) work
as expected. The default `global` caching in Pluto creates problems with the
math display.
"""
force_pluto_mathjax_local() = FORCE_MATHJAX_LOCAL[]
force_pluto_mathjax_local(flag::Bool) = FORCE_MATHJAX_LOCAL[] = flag