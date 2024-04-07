//@ts-check
import { html } from "https://esm.sh/gh/observablehq/stdlib@v5.8.6/src/html.js";
import { addClipboardHeader } from "./clipboard.js";
import { addContainerStyle } from "./styles.js";
/**
 * Creates the Container element used by PlutoPlotly to wrap the plotly.js plot and adds additional functionality like resizing and enhanced clipboard.
 *
 * @param {import("./typedef.js").Plotly} Plotly - The Plotly object. Defaults to globalThis.Plotly.
 * @return {import("./typedef.js").Container} The container element for the Plotly plot.
 */
export function makeContainer(Plotly = globalThis.Plotly) {
  const /** @type {import("./typedef.js").Container} */ CONTAINER = html`<div class="plutoplotly-container"></div>`;
  CONTAINER.Plotly = Plotly
  // Add the style to it
  addContainerStyle(CONTAINER);
  // Add the clipboard header
  addClipboardHeader(CONTAINER);
  // Create the child div that will contain the actual plot
  const PLOT = CONTAINER.PLOT = CONTAINER.appendChild(
    html`<div class="plutoplotly-plot"></div>`
  );
  // We set the flag of remove
  CONTAINER.remove_container_size = true
  // We use a controller to remove event listeners upon invalidation
  CONTAINER.controller = new AbortController();
  // We have to add this to keep supporting @bind with the old API using PLOT
  // TO REMOVE NOW WITH JS MIGRATION? WE ARE ANYHOW BREAKING
  PLOT.addEventListener(
    "input",
    (/** @type {Event} */ e) => {
      CONTAINER.value = PLOT.value;
      if (e.bubbles) {
        return;
      }
      CONTAINER.dispatchEvent(new CustomEvent("input"));
    },
    { signal: CONTAINER.controller.signal }
  );
  // We add a function to check if the clipboard is popped out
  CONTAINER.isPoppedOut = function() {
    return this.classList.contains("popped-out");
  };
  return CONTAINER
}