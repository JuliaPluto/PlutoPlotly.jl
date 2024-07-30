import { mergeDeps } from "./global_deps.js";

/**
 * Adds a container style to the specified container element.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to which the style will be added
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addContainerStyle(CONTAINER, deps = CONTAINER.js_deps) {
  const {
    emotion: { css },
  } = mergeDeps(deps);
  const cl = css`
    &.popped-out {
      overflow: hidden;
      z-index: 1000;
      position: fixed;
      background: var(--main-bg-color, var(--bg-color));
      border: 3px solid var(--kbd-border-color, var(--border-color));
      border-radius: 12px;
      border-top-left-radius: 12px;
      border-top-right-radius: 12px;
      top: var(--element-top, 'auto');
      left: var(--element-left, 'auto');
      box-sizing: content-box;
      max-width: calc(100vw - var(--max-width-offset));
      max-height: calc(100vh - var(--max-height-offset));
    }
    &.popped-out .plot-pane-container {
      overflow: auto;
      max-width: calc(100vw - var(--max-width-offset));
      max-height: calc(100vh - var(--max-height-offset));
    }
    // We add defaults color variables for outside Pluto
    @media (prefers-color-scheme: light) {
      --border-color: #dfdfdf;
      --bg-color: white;
      --tag-color: #ef6155;
      --macro-color: #5c8c5f;
      --output-color: hsl(0, 0%, 25%);
    }
    @media (prefers-color-scheme: dark) {
      --border-color: #222222;
      --bg-color: hsl(0deg 0% 12%);
      --tag-color: #ef6155;
      --macro-color: #82b38b;
      --output-color: hsl(0deg 0% 77%);
    }
  `;
  CONTAINER.classList.add(cl);
}

/**
 * Adds the clipboard header style to the given element.
 *
 * @param {HTMLElement} element - the element to which the clipboard header style will be added
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addClipboardHeaderStyle(element, deps = {}) {
  const {
    emotion: { css },
  } = mergeDeps(deps);
  const cl = css`
    & {
      display: none;
      flex-flow: row wrap;
      background: var(--main-bg-color, var(--bg-color));
      cursor: move;
      padding: 5px;
      align-items: center;
      user-select: none;
    }
    .popped-out & {
      border-bottom: 3px solid var(--kbd-border-color, var(--border-color));
      display: flex;
    }
    & span {
      display: inline-block;
      flex: 1;
    }
    &.hidden {
      display: none;
    }
    & .clipboard-span {
      position: relative;
    }
    & .clipboard-value {
      padding-right: 5px;
      padding-left: 2px;
      cursor: text;
    }
    & .config-value {
      font-weight: normal;
      color: var(--pluto-output-color, var(--output-color));
      display: block;
      visibility: hidden;
      position: fixed;
      z-index: 2000;
      background: var(--main-bg-color, var(--bg-color));
      border: 3px solid var(--kbd-border-color, var(--border-color));
      border-radius: 12px;
      padding: 5px;
      max-width: 250px;
      transition: visibility 0.25s;
    }
    & .config-value p:first-child {
      margin-block-start: 0;
    }
    & .config-value p:last-child {
      margin-block-end: 0;
    }
    & .label {
      user-select: none;
    }
    & .label:hover span.config-value {
      visibility: visible;
      transition: visibility 0s;
    }
    & .clipboard-span[config="matching"] .label {
      color: var(--cm-macro-color, var(--macro-color));
      font-weight: bold;
    }
    & .clipboard-span[config="different"] .label {
      color: var(--cm-tag-color, var(--tag-color));
      font-weight: bold;
    }
    & .clipboard-span.format {
      display: none;
    }
    & .clipboard-span.filename {
      flex: 0 0 100%;
      text-align: center;
      border-top: 3px solid var(--kbd-border-color, var(--border-color));
      margin-top: 5px;
      display: none;
    }
    .filesave-extras & .clipboard-span.filename {
      display: inline-block;
    }
    & .clipboard-value.filename {
      margin-left: 3px;
      text-align: left;
      min-width: min(60%, min-content);
    }
    .filesave-extras & .clipboard-span.format {
      display: inline-flex;
    }

    & button {
      background-color: #4caf50; /* Green background */
      border: none; /* Remove border */
      color: white; /* White text */
      padding: 5px 10px; /* Some padding */
      text-align: center; /* Centered text */
      text-decoration: none; /* Remove underline */
      display: inline-block; /* Make the buttons appear side by side */
      font-size: 13px; /* Increase font size */
      margin: 4px 2px; /* Some margin */
      cursor: pointer; /* Pointer/hand icon on hover */
      border-radius: 12px; /* Rounded corners */
      transition: background-color 0.3s, box-shadow 0.3s; /* Smooth transition for hover effects */
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Subtle shadow */
    }

    & button:hover {
      background-color: #45a049; /* Darker green on hover */
      box-shadow: 0 6px 8px rgba(0, 0, 0, 0.2); /* Slightly bigger shadow on hover */
    }

    & button:active {
      background-color: #3e8e41; /* Even darker green when clicked */
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Shadow back to normal when clicked */
      transform: translateY(2px); /* Slight move down effect when clicked */
    }
  `;
  element.classList.add(cl);
}

/**
 * @param {HTMLElement} element - the element to which the clipboard header style will be added
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addFormatConfigStyle(element, deps = {}) {
  const {
    emotion: { css },
  } = mergeDeps(deps);
  const format_config_style = css`
    & > .label {
      flex: 0 0 0;
    }
    & .clipboard-value {
      position: relative;
      flex: 1 0 auto;
      min-width: 30px;
      margin-right: 10px;
    }
    & .format-options {
      display: inline-flex;
      flex-flow: column;
      position: absolute;
      background: var(--main-bg-color, var(--bg-color));
      border-radius: 12px;
      padding-left: 3px;
      z-index: 2000;
    }
    & .format-options:hover {
      cursor: pointer;
      border: 3px solid var(--kbd-border-color, var(--border-color));
      padding: 3px;
      transform: translate(-3px, -6px);
    }
    & .format-option {
      display: none;
      margin-top: 3px;
    }
    & .format-options:hover .format-option {
      display: inline-block;
    }
    & .format-options[selected="png"] .format-option.png,
    & .format-options[selected="svg"] .format-option.svg,
    & .format-options[selected="webp"] .format-option.webp,
    & .format-options[selected="jpeg"] .format-option.jpeg,
    & .format-options[selected="full-json"] .format-option.full-json {
      margin-top: 0px;
      order: -1;
      display: inline-block;
    }
    & .format-options .format-option:hover {
      background-color: var(--kbd-border-color, var(--border-color));
    }
  `;
  element.classList.add(format_config_style);
}

/**
 * Adds a plot_pane style to the specified element.
 *
 * @param {HTMLElement} PLOT_PANE - The PLOT PANE, which will contain the actual plotlyjs plot
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addPlotPaneStyle(PLOT_PANE, deps = {}) {
  const {
    emotion: { css },
  } = mergeDeps(deps);
  const cl = css`
    & {
      width: 100%;
      height: 100%;
      min-height: 0;
      min-width: 0;
      margin: 0;
      padding: 0;
    }
    .popped-out & {
      width: var(--plot-width);
      height: var(--plot-height);
    }
    & .js-plotly-plot .plotly div {
      margin: 0 auto; // This centers the plot
    }
  `;
  PLOT_PANE.classList.add(cl);
}
