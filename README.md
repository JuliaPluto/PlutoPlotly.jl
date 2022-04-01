# PlutoPlotly.jl

This package provides a wrapper type `PlutoPlot` around the `Plot` type from [PlotlyBase.jl](https://github.com/sglyon/PlotlyBase.jl) that exposes the [plotly library](https://plotly.com/julia/).

The wrapper mostly defines a custom `show` method specifically optimized for displaying inside of [Pluto.jl](https://github.com/fonsp/Pluto.jl/) and adds the options of providing custom javascript functions to attach to the [plolty JS events](https://plotly.com/javascript/plotlyjs-events/) 

Basic use of this package is to load this inside Pluto instead of PlotlyBase or PlotlyJS, and then simply wrap the intended `Plot` objects from PlotlyBase inside a PlutoPlot as
```julia
p = Plot(args...)
PlutoPlot(p)
```

# Features

## Persistent Layout

The custom show method relies on the [`Plotly.react`](https://plotly.com/javascript/plotlyjs-function-reference/#plotlyreact) function, which is optimized for updating or re-plotting data on an existing graph object, making it ideal in combination with Pluto's reactivity. The data transfer between Pluto and the browser also exploits Pluto's own `publish_to_js` function which is usually faster than standard JSON serialization, especially for big datasets.

One advantage of using `react` as opposed to `newPlot` from the Plotly library is that one can have the layout (e.g. zoom level, camera view angle, etc...) persist across reactive re-runs by exploiting the [`uirevision`](https://plotly.com/javascript/uirevision/) attribute of Plotly layouts:


## Return values to Julia using @bind

The possibility of attaching event listeners to the plotly events allows to create nice interactivity between Julia and Pluto using the `@bind` macro

### Coordinates of the clicked point

### Filtering of visible points in the plot

View [the wrapper notebook](./notebooks/wrapper.jl) for more details and examples.