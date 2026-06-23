// The ONLY Pluto-aware file. A VSCode adapter would be its sibling.
// Expects in closure scope (from the Julia preamble in src/show.jl + the css
// binding in src/main_struct.jl): plot_obj, Plotly, plotly_listeners,
// js_listeners, html, css; and Pluto's injected `this` / `invalidation`.
// `CONTAINER` is returned to Pluto by `return CONTAINER` in src/show.jl.

const firstRun = this ? false : true;
const CONTAINER = this ?? makeContainer(Plotly, html, css);

// `PLOT` is a DOCUMENTED in-scope variable for user listeners
// (add_js_listener! / add_plotly_listener! docstrings). Keep it bound so existing
// user listener code referencing bare `PLOT` keeps working.
const PLOT = CONTAINER.PLOT;

// Capture THIS run's teardown handles; CONTAINER is reused across re-runs, so
// cleaning up these locals (not CONTAINER.*) avoids clobbering the next run.
const { controller, resizeObserver } = updatePlotData(
  CONTAINER,
  plot_obj,
  { plotlyListeners: plotly_listeners, jsListeners: js_listeners },
  firstRun
);

invalidation.then(() => {
  // Remove all plotly listeners
  PLOT.removeAllListeners();
  // Remove the @bind forwarder + all JS listeners added this run
  controller.abort();
  // Remove this run's resizeObserver
  resizeObserver.disconnect();
});
