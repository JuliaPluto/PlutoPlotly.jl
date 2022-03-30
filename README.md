# PlutoPlotly.jl

This package provides a wrapper type `PlutoPlot` around the `Plot` type from [PlotlyBase.jl](https://github.com/sglyon/PlotlyBase.jl) that exposes the [plotly library](https://plotly.com/julia/).

The wrapper mostly defines a custom `show` method specifically optimized for displaying inside of [Pluto.jl](https://github.com/fonsp/Pluto.jl/) and adds the options of providing custom javascript functions to attach to the [plolty JS events](https://plotly.com/javascript/plotlyjs-events/) 

Basic use of this package is to load this inside Pluto instead of PlotlyBase or PlotlyJS, and then simply wrap the intended `Plot` objects from PlotlyBase inside a PlutoPlot as
```julia
p = Plot(args...)
PlutoPlot(p)
```

View [the wrapper notebook](./notebooks/wrapper.jl) for more details and examples.