# PlutoPlotly.jl

This package provides some convenience methods for easy plotting inside Pluto notebooks using the [plotly library](https://plotly.com/julia/).

At the moment, this package mostly `@reexport` PlotlyBase overriding the default `show` method for `Plot` objects on HTML output.
View [the examples notebook](./notebooks/plotly_show_examples.jl) for more details.