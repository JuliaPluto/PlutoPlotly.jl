import { mergeDeps } from "./global_deps.js";

/**
 * Adds a container style to the specified container element.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to which the style will be added
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addContainerStyle(CONTAINER, deps = {}) {
  const { emotion: {css} } = mergeDeps(deps)
  const cl = css`
    & {
      position: relative;
      width: 100%;
      height: 100%;
      min-height: 0;
      min-width: 0;
    }
    & .js-plotly-plot .plotly div {
      margin: 0 auto; // This centers the plot
    }
    &.popped-out {
      overflow: show;
      z-index: 1000;
      position: fixed;
      resize: both;
      background: var(--main-bg-color, var(--bg-color));
      border: 3px solid var(--kbd-border-color, var(--border-color));
      border-radius: 12px;
      border-top-left-radius: 0px;
      border-top-right-radius: 0px;
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
  const { emotion: {css} } = mergeDeps(deps)
  const cl = css`
    & {
      display: flex;
      flex-flow: row wrap;
      background: var(--main-bg-color, var(--bg-color));
      border: 3px solid var(--kbd-border-color, var(--border-color));
      border-top-left-radius: 12px;
      border-top-right-radius: 12px;
      position: absolute;
      z-index: 1001;
      cursor: move;
      transform: translate(0px, -100%);
      padding: 5px;
      width: 100%;
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
      display: none;
      position: absolute;
      background: var(--main-bg-color, var(--bg-color));
      border: 3px solid var(--kbd-border-color, var(--border-color));
      border-radius: 12px;
      transform: translate(0px, calc(-100% - 10px));
      padding: 5px;
    }
    & .label {
      user-select: none;
    }
    & .label:hover span.config-value {
      display: inline-block;
      min-width: 150px;
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
    &.filesave-extras .clipboard-span.filename {
      display: inline-block;
    }
    & .clipboard-value.filename {
      margin-left: 3px;
      text-align: left;
      min-width: min(60%, min-content);
    }
    &.filesave-extras .clipboard-span.format {
      display: inline-flex;
    }
  `;
  element.classList.add(cl);
}

/**
 * @param {HTMLElement} element - the element to which the clipboard header style will be added
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - The object containing the emotion library as property
 */
export function addFormatConfigStyle(element, deps = {}) {
  const { emotion: {css} } = mergeDeps(deps)
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
  const { emotion: {css} } = mergeDeps(deps)
  const cl = css`
    & {
      width: 100%;
      height: 100%;
      min-height: 0;
      min-width: 0;
    }
    & .js-plotly-plot .plotly div {
      margin: 0 auto; // This centers the plot
    }
  `;
  PLOT_PANE.classList.add(cl);
}