import { libs } from "./global_deps.js";

/**
 * Adds a container style to the specified container element.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to which the style will be added
 */
export function addContainerStyle(CONTAINER) {
  const css = libs.emotion.css;
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
    &.popped-out {
      overflow: auto;
      z-index: 1000;
      position: fixed;
      resize: both;
      background: var(--main-bg-color);
      border: 3px solid var(--kbd-border-color);
      border-radius: 12px;
      border-top-left-radius: 0px;
      border-top-right-radius: 0px;
    }
  `;
  CONTAINER.classList.add(cl);
}


/**
 * Adds the clipboard header style to the given element.
 *
 * @param {HTMLElement} element - the element to which the clipboard header style will be added
 */
export function addClipboardHeaderStyle(element) {
  const css = libs.emotion.css
  const cl = css`
  & {
    display: flex;
    flex-flow: row wrap;
    background: var(--main-bg-color);
    border: 3px solid var(--kbd-border-color);
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
    position: fixed;
    z-index: 1001;
    cursor: move;
    transform: translate(0px, -100%);
    padding: 5px;
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
    color: var(--pluto-output-color);
    display: none;
    position: absolute;
    background: var(--main-bg-color);
    border: 3px solid var(--kbd-border-color);
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
  & .clipboard-span.matching-config .label {
    color: var(--cm-macro-color);
    font-weight: bold;
  }
  & .clipboard-span.different-config .label {
    color: var(--cm-tag-color);
    font-weight: bold;
  }
  & .clipboard-span.format {
    display: none;
  }
  & .clipboard-span.filename {
    flex: 0 0 100%;
    text-align: center;
    border-top: 3px solid var(--kbd-border-color);
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
 */
export function addFormatConfigStyle(element) {
  const css = libs.emotion.css
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
    background: var(--main-bg-color);
    border-radius: 12px;
    padding-left: 3px;
    z-index: 2000;
  }
  & .format-options:hover {
    cursor: pointer;
    border: 3px solid var(--kbd-border-color);
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
    background-color: var(--kbd-border-color);
  }
`;
  element.classList.add(format_config_style);
}
