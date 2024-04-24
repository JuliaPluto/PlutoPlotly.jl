//@ts-check
import { GlobalDeps } from "./global_deps.js";
import { addClipboardHeader, toImageOptionKeys } from "./clipboard.js";
import { addContainerStyle } from "./styles.js";
/**
 * Creates the Container element used by PlutoPlotly to wrap the plotly.js plot and adds additional functionality like resizing and enhanced clipboard.
 *
 * @param {import("./typedef.js").Plotly} Plotly - The Plotly object. Defaults to globalThis.Plotly.
 * @return {import("./typedef.js").Container} The container element for the Plotly plot.
 */
export function makeContainer(Plotly = globalThis.Plotly, { html } = GlobalDeps) {
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
  // We add the function to extract the image options for saving/copying
  CONTAINER.toImageOptions = toImageOptions
  return CONTAINER
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