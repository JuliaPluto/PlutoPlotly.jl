//@ts-check
import { mergeDeps } from "./global_deps.js";
import { addClipboardHeader, toImageOptionKeys } from "./clipboard.js";
import { addContainerStyle, addPlotPaneStyle } from "./styles.js";
/**
 * Creates the Container element used by PlutoPlotly to wrap the plotly.js plot and adds additional functionality like resizing and enhanced clipboard.
 *
 * @param {import("./typedef.js").Plotly} Plotly - The Plotly object. Defaults to globalThis.Plotly.
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - An optional object containing the JS dependencies to use, which are 'html', 'emotion', 'lodash' and 'interact'.
 * @return {import("./typedef.js").Container} The container element for the Plotly plot.
 */
export function makeContainer(Plotly = globalThis.Plotly, deps = {}) {
  const { html } = mergeDeps(deps)
  const /** @type {import("./typedef.js").Container} */ CONTAINER = html`<div class="plutoplotly-container"></div>`;
  CONTAINER.Plotly = Plotly
  // Add the style to it
  addContainerStyle(CONTAINER, deps);
  // Add the clipboard header
  addClipboardHeader(CONTAINER, deps);
  // Add the Plot Pane
  addPlotPane(CONTAINER, deps);
  // Create the child div that will contain the actual plot
  const PLOT = CONTAINER.PLOT = CONTAINER.PLOT_PANE.appendChild(
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
  // We add the function to extract the image options for saving/copying
  CONTAINER.toImageOptions = toImageOptions
  return CONTAINER
}

/**
 * Add the plot data to the already created CONTAINER and update the plot
 *
 * @param {import("./typedef.js").Container} CONTAINER - The plutoplotly Container.
 * @param {import("./typedef.js").PlotObj} plot_data - An optional object containing the JS dependencies to use, which are 'html', 'emotion', 'lodash' and 'interact'.
 * @return {undefined} This function does not return anything.
 */
export function updatePlotData(CONTAINER, plot_data) {
  // Extract the plotly library
  const { Plotly, PLOT } = CONTAINER
  CONTAINER.plot_data = plot_data
  Plotly.react(PLOT, plot_data)
}

/**
 * Compute the `position` field of the provided `CONTAINER` using getBoundingClientRect.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The CONTAINER object to update.
 * @return {DOMRect} the function does not return a value.
 */
function computeContainerPosition(CONTAINER) {
  CONTAINER.position = CONTAINER.getBoundingClientRect();
  return CONTAINER.position
}

/**
 * Updates the position of the CONTAINER based on the provided left and top values.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to update.
 * @param {DOMRect} [position] }
 * @return {undefined} the function does not return a value.
 */
export function updateContainerPosition(CONTAINER, position) {
  CONTAINER.position = position ?? computeContainerPosition(CONTAINER)
  const { left, top } = CONTAINER.position
  CONTAINER.style.setProperty('--element-top', top + 'px')
  CONTAINER.style.setProperty('--element-left', left + 'px')
}

/**
 * Adds a clipboard header to the given container.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container to which the clipboard header will be added.
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least html
 * @return {undefined} span function does not return a value.
 */
function addPlotPane(CONTAINER, deps = {}) { 
  const { html } = mergeDeps(deps)
  // Return if the PLOT_PANE has been assigned already
  if (CONTAINER.PLOT_PANE !== undefined) return;
  const PLOT_PANE = CONTAINER.PLOT_PANE = html`<div class='plutoplotly-plot-pane'></div>`;
  addPlotPaneStyle(PLOT_PANE, deps);
  CONTAINER.appendChild(PLOT_PANE);
}

/**
 * Extracts the image options from the clipboard header
 * @this {import("./typedef.js").Container}
 */
function toImageOptions() {
    const { CLIPBOARD_HEADER } = this
    /** @type {Partial<import("./typedef.js").toImageOptions>} */
    const options = {}
    for (const key of toImageOptionKeys) {
      const config_value = CLIPBOARD_HEADER.config_values[key]
      const ui_value = CLIPBOARD_HEADER.ui_values[key]
      const isPopped = this.isPoppedOut()
      const value = config_value ?? (isPopped ? ui_value : undefined)
      if (value !== undefined) {
        options[key] = value
      }
    }
    return options
}