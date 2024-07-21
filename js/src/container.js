//@ts-check
import { mergeDeps } from "./global_deps.js";
import { addClipboardFunctionality, toImageOptionKeys } from "./clipboard.js";
import { addContainerStyle, addPlotPaneStyle } from "./styles.js";
/**
 * Creates the Container element used by PlutoPlotly to wrap the plotly.js plot and adds additional functionality like resizing and enhanced clipboard.
 *
 * @param {import("./typedef.js").Plotly} Plotly - The Plotly object. Defaults to globalThis.Plotly.
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - An optional object containing the JS dependencies to use, which are 'html', 'emotion', 'lodash' and 'interact'.
 * @return {import("./typedef.js").Container} The container element for the Plotly plot.
 */
export function makeContainer(Plotly = globalThis.Plotly, deps = {}) {
  const js_deps = mergeDeps(deps);
  const { html } = js_deps;
  const /** @type {import("./typedef.js").Container} */ CONTAINER = html`<div
      class="plutoplotly-container"
    ></div>`;
  CONTAINER.Plotly = Plotly;
  CONTAINER.js_deps = js_deps;
  // Add the style to it
  addContainerStyle(CONTAINER);
  // Add the Plot Pane
  addPlotPane(CONTAINER);
  // Create the child div that will contain the actual plot
  const PLOT = (CONTAINER.PLOT = CONTAINER.PLOT_PANE.appendChild(
    html`<div class="plutoplotly-plot"></div>`
  ));
  const resizeObserver = (CONTAINER.resizeObserver = new ResizeObserver(
    (entries) => {
      if (!PLOT.hasChildNodes()) return; // We skip if no plot has been added yet
      const lastEntry = entries[entries.length - 1];
      const { width, height } = lastEntry.contentRect;
      Plotly.relayout(PLOT, { width, height });
    }
  ));
  resizeObserver.observe(CONTAINER.PLOT_PANE);
  // We set the flag of remove
  CONTAINER.remove_container_size = true;
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
  CONTAINER.isPoppedOut = function () {
    return this.classList.contains("popped-out");
  };
  // We add the function to extract the image options for saving/copying
  CONTAINER.toImageOptions = toImageOptions;
  return CONTAINER;
}

/**
 * Add the plot data to the already created CONTAINER and update the plot
 *
 * @param {import("./typedef.js").Container} CONTAINER - The plutoplotly Container.
 * @param {import("./typedef.js").PlotObj} plot_obj - An optional object containing the JS dependencies to use, which are 'html', 'emotion', 'lodash' and 'interact'.
 * @return {undefined} This function does not return anything.
 */
export function updatePlotData(CONTAINER, plot_obj) {
  // Extract the plotly library
  const { Plotly, PLOT, js_deps } = CONTAINER;
  const { lodash } = js_deps;
  // We make the plot responsive if the plot_data does not contain a specific value for it
  if (!lodash.has(plot_obj, "config.responsive")) {
    lodash.set(plot_obj, "config.responsive", true);
  }
  CONTAINER.plot_obj = plot_obj;
  // Add the clipboard header
  addClipboardFunctionality(CONTAINER);
  Plotly.react(PLOT, plot_obj);
}

/**
 * Updates the position of the CONTAINER based on the provided left and top values.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to update.
 * @param {DOMRect} target_plot_rect }
 * @return {undefined} the function does not return a value.
 */
export function updateContainerPosition(CONTAINER, target_plot_rect) {
  const cr = CONTAINER.getBoundingClientRect();
  const tpr = target_plot_rect;
  const pr = CONTAINER.PLOT_PANE.getBoundingClientRect();

  const header_height = cr.height - pr.height

  const computedStyle = getComputedStyle(CONTAINER);
  const border = {
    top: parseFloat(computedStyle.getPropertyValue("border-top-width")),
    right: parseFloat(computedStyle.getPropertyValue("border-right-width")),
    bottom: parseFloat(computedStyle.getPropertyValue(
    "border-bottom-width"
  )),
    left: parseFloat(computedStyle.getPropertyValue("border-left-width"))
  }
  const top_offset = tpr.top - pr.top;
  const left_offset = tpr.left - pr.left;
  const top = cr.top + top_offset;
  const left = cr.left + left_offset;
  const { PLOT_PANE } = CONTAINER;
  const PLOT_PANE_CONTAINER = PLOT_PANE.parentElement

  CONTAINER.style.setProperty("--element-top", top + "px");
  CONTAINER.style.setProperty("--element-left", left + "px");
  // The 3 belows are to
  CONTAINER.style.setProperty(
    "--max-width-offset",
    tpr.left + border.left + border.right + 3 + "px"
  );
  CONTAINER.style.setProperty(
    "--max-height-offset",
    tpr.top - header_height + border.bottom + 3 + "px"
  );
  // @ts-ignore we are sure the container is not null
  PLOT_PANE_CONTAINER.style.setProperty(
    "--max-height-offset",
    tpr.top + border.bottom + 3 + "px"
  );

  PLOT_PANE.style.setProperty("--plot-width", tpr.width + "px");
  PLOT_PANE.style.setProperty("--plot-height", tpr.height + "px");
}

/**
 * Adds a clipboard header to the given container.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container to which the clipboard header will be added.
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least html
 * @return {undefined} span function does not return a value.
 */
function addPlotPane(CONTAINER, deps = CONTAINER.js_deps) {
  const { html } = mergeDeps(deps);
  // Return if the PLOT_PANE has been assigned already
  if (CONTAINER.PLOT_PANE !== undefined) return;
  const PLOT_PANE_CONTAINER = CONTAINER.appendChild(
    html`<div class="plutoplotly plot-pane-container"></div>`
  );
  const PLOT_PANE = (CONTAINER.PLOT_PANE = html`<div
    class="plutoplotly plot-pane"
  ></div>`);
  addPlotPaneStyle(PLOT_PANE, deps);
  PLOT_PANE_CONTAINER.appendChild(PLOT_PANE);
}

/**
 * Extracts the image options from the clipboard header
 * @this {import("./typedef.js").Container}
 */
function toImageOptions() {
  const { CLIPBOARD_HEADER } = this;
  /** @type {Partial<import("./typedef.js").toImageOptions>} */
  const options = {};
  for (const key of toImageOptionKeys) {
    const config_value = CLIPBOARD_HEADER.config_values[key];
    const ui_value = CLIPBOARD_HEADER.ui_values[key];
    const isPopped = this.isPoppedOut();
    const value = config_value ?? (isPopped ? ui_value : undefined);
    if (value !== undefined) {
      options[key] = value;
    }
  }
  return options;
}
