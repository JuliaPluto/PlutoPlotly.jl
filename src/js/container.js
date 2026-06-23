// Pluto-agnostic construction and update of the plot container.
// All per-plot state is stored on the CONTAINER element so the rest of the core
// (clipboard.js / resizer.js) can read it without shared script-scope globals.
// Expects in scope: addClipboardFunctionality (clipboard.js),
// addResizeFunctionality (resizer.js). `html`/`Plotly`/`css` are passed in.

// Build the container element once (only called on first creation; on a
// reactive re-run the host adapter reuses the existing container).
function makeContainer(Plotly, html, css) {
  const CONTAINER = html`<div class='plutoplotly-container'></div>`;
  CONTAINER.Plotly = Plotly;
  // Inject the stylesheet once.
  CONTAINER.appendChild(html`<style>${css}</style>`);
  // Child div that holds the actual Plotly plot.
  const PLOT = (CONTAINER.PLOT = CONTAINER.appendChild(html`<div></div>`));
  // Controller used to remove event listeners on invalidation.
  CONTAINER.controller = new AbortController();
  // Keep supporting @bind with the old API using PLOT.
  PLOT.addEventListener(
    "input",
    (e) => {
      CONTAINER.value = PLOT.value;
      if (e.bubbles) {
        return;
      }
      CONTAINER.dispatchEvent(new CustomEvent("input"));
    },
    { signal: CONTAINER.controller.signal }
  );
  CONTAINER.isPoppedOut = () => CONTAINER.classList.contains("popped-out");
  return CONTAINER;
}

// Stash the per-plot data on CONTAINER, wire clipboard + resize behaviour, then
// render and attach the user listeners. Runs on every (re-)render.
function updatePlotData(CONTAINER, plot_obj, listeners = {}, firstRun = true) {
  const { Plotly, PLOT } = CONTAINER;
  CONTAINER.plot_obj = plot_obj;
  CONTAINER.original_height = plot_obj.layout?.height;
  CONTAINER.original_width = plot_obj.layout?.width;
  // Flag: remove the fixed inline height/width after the first resize.
  CONTAINER.remove_container_size = firstRun;
  // Fixed height in case the plot sits in a non-fixed-size wrapper (the default).
  const container_height =
    CONTAINER.original_height ?? PLOT.container_height ?? 400;
  CONTAINER.style.height = container_height + "px";
  addClipboardFunctionality(CONTAINER, firstRun);
  addResizeFunctionality(CONTAINER, firstRun);
  return Plotly.react(PLOT, plot_obj).then(() => {
    const { plotlyListeners = {}, jsListeners = {} } = listeners;
    for (const [key, listener_vec] of Object.entries(plotlyListeners)) {
      for (const listener of listener_vec) {
        PLOT.on(key, listener);
      }
    }
    for (const [key, listener_vec] of Object.entries(jsListeners)) {
      for (const listener of listener_vec) {
        PLOT.addEventListener(key, listener, {
          signal: CONTAINER.controller.signal,
        });
      }
    }
  });
}
