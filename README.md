# PlutoPlotly.jl
[![Build Status](https://github.com/JuliaPluto/PlutoPlotly.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaPluto/PlutoPlotly.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaPluto/PlutoPlotly.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaPluto/PlutoPlotly.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

This package provides a wrapper type `PlutoPlot` around the `Plot` type from [PlotlyBase.jl](https://github.com/sglyon/PlotlyBase.jl) that exposes the [plotly library](https://plotly.com/julia/).

The wrapper mostly defines a custom `show` method specifically optimized for displaying inside of [Pluto.jl](https://github.com/fonsp/Pluto.jl/) and adds the options of providing custom javascript functions to attach to the [plolty JS events](https://plotly.com/javascript/plotlyjs-events/) 

You can load the PlutoPlotly package *instead of* PlotlyBase or PlotlyJS, and replace `Plot` with `plot` from PlutoPlotly. For example:

```julia
plot([5,6,7,2]; line_color="red")
```

You can also create a PlotlyBase `Plot`, and then wrap it inside a `PlutoPlot` object:
```julia
let
    # create a PlotlyBase function
    p = Plot(args...)
    # wrap it
    PlutoPlot(p)
end
```

(The function `plot(args...)` from PlutoPlotly is the same as `PlutoPlot(Plot(args...))`.)

# Features

## Persistent Layout

The custom show method relies on the [`Plotly.react`](https://plotly.com/javascript/plotlyjs-function-reference/#plotlyreact) function, which is optimized for updating or re-plotting data on an existing graph object, making it ideal in combination with Pluto's reactivity. The data transfer between Pluto and the browser also exploits Pluto's own `publish_to_js` function which is usually faster than standard JSON serialization, especially for big datasets.

One advantage of using `react` as opposed to `newPlot` from the Plotly library is that one can have the layout (e.g. zoom level, camera view angle, etc...) persist across reactive re-runs by exploiting the [`uirevision`](https://plotly.com/javascript/uirevision/) attribute of Plotly layouts:

https://user-images.githubusercontent.com/12846528/161222951-bbe65007-334c-45aa-b44a-aa3ef548f01a.mp4

## Return values to Julia using @bind

The possibility of attaching event listeners to the plotly events allows to create nice interactivity between Julia and Pluto using the `@bind` macro

### Coordinates of the clicked point

https://user-images.githubusercontent.com/12846528/161222881-4e9aeed6-bcb2-495b-8f19-eadca62b33da.mp4

### Filtering only visible points in the plot

https://user-images.githubusercontent.com/12846528/161222655-c07e4ea2-5965-4aac-beb3-4ff42cdcffe4.mp4

View the notebooks inside [the notebook](./notebooks/) subfolder for more details and examples. Note that the notebooks have to be opened from the package folder as they directly load the latest version of the package (and do so from the path they are called from)
