// This file contains utilities to be executed before calling the plot function.
import { default as _ } from "https://esm.sh/lodash@4.17.21";
import { html } from "https://esm.sh/gh/observablehq/stdlib@v5.8.6/src/html.js";
import { addContainerStyle } from "./styles.js";

// We start by putting all the variable interpolation here at the beginning
// We have to convert all typedarrays in the layout to normal arrays. See Issue #25
// We use lodash for this for compactness
function removeTypedArray(o) {
  return _.isTypedArray(o)
    ? Array.from(o)
    : _.isPlainObject(o)
    ? _.mapValues(o, removeTypedArray)
    : o;
}

export function makeContainer(caller_this) {
  if (caller_this !== undefined) {
    // If our input is already the container we just update its flag and return it
    caller_this.firstRun = false;
    return caller_this;
  }
  const CONTAINER = html`<div class="plutoplotly-container"></div>`;
  // Add the style to it
  addContainerStyle(CONTAINER);
  // Create the child div that will contain the actual plot
  const PLOT = CONTAINER.appendChild(
    html`<div class="plutoplotly-plot"></div>`
  );
  CONTAINER.PLOT = PLOT;
  // We use a controller to remove event listeners upon invalidation
  CONTAINER.controller = new AbortController();
  // We have to add this to keep supporting @bind with the old API using PLOT
  // TO REMOVE NOW WITH JS MIGRATION? WE ARE ANYHOW BREAKING
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
  return CONTAINER
}

export function createPlot(plot_obj) {
  const CONTAINER = makeContainer();
  const { PLOT } = CONTAINER;
  // Record or update the layout width/height if provided explicitly
	PLOT.layout_size = {
    height: plot_obj.layout.height,
    width: plot_obj.layout.width,
  }
	// For the height we have to also put a fixed value in case the plot is put on a non-fixed-size container (like the default wrapper)
	// We define a variable to check whether we still have to remove the fixed height
	let remove_container_size = firstRun
	let container_height = original_height ?? PLOT.container_height ?? 400
	CONTAINER.style.height = container_height + 'px'
}