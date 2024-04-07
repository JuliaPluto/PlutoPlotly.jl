// This file contains utilities to be executed before calling the plot function.
// import { interact, html, lodash as _ } from "./url_imports.js"
import { makeContainer } from "./container.js";
import { processPlotObj } from "./utils.js";
import { setGlobalDeps, validGlobalDeps } from "./global_deps.js";
export { setGlobalDeps, validGlobalDeps, makeContainer }

// We start by putting all the variable interpolation here at the beginning
// We have to convert all typedarrays in the layout to normal arrays. See Issue #25

export function createPlot(plot_obj, Plotly = globalThis.Plotly) {
  const CONTAINER = makeContainer();
  const { PLOT } = CONTAINER;
  // Record or update the layout width/height if provided explicitly
	PLOT.layout_size = {
    height: plot_obj.layout.height,
    width: plot_obj.layout.width,
  }
  // Removed typed arrays from the layout
  const _plot_obj = processPlotObj(plot_obj)
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	// We define a variable to check whether we still have to remove the fixed height
	let container_height = PLOT.layout_size.height ?? PLOT.container_height ?? 400
	CONTAINER.style.height = container_height + 'px'
  Plotly.react(PLOT, _plot_obj)
  return CONTAINER
}

export function lol(a = globalThis.asd) {
  console.log("LOL: ", a)
}