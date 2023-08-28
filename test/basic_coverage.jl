using Test
using PlutoPlotly

@test force_pluto_mathjax_local() === false
force_pluto_mathjax_local(true)
@test force_pluto_mathjax_local() === true