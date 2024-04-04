import { css } from "./url_imports.js";

const CONTAINER_STYLE = css`
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
    .plutoplotly-clipboard-header {
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
    .plutoplotly-clipboard-header span {
      display: inline-block;
      flex: 1;
    }
    .plutoplotly-clipboard-header.hidden {
      display: none;
    }
    .clipboard-span {
      position: relative;
    }
    .clipboard-value {
      padding-right: 5px;
      padding-left: 2px;
      cursor: text;
    }
    .clipboard-span.format {
      display: none;
    }
    .clipboard-span.filename {
      flex: 0 0 100%;
      text-align: center;
      border-top: 3px solid var(--kbd-border-color);
      margin-top: 5px;
      display: none;
    }
    &.filesave .clipboard-span.filename {
      display: inline-block;
    }
    .clipboard-value.filename {
      margin-left: 3px;
      text-align: left;
      min-width: min(60%, min-content);
    }
    &.filesave .clipboard-span.format {
      display: inline-flex;
    }
    .clipboard-span.format .label {
      flex: 0 0 0;
    }
    .clipboard-value.format {
      position: relative;
      flex: 1 0 auto;
      min-width: 30px;
      margin-right: 10px;
    }
    div.format-options {
      display: inline-flex;
      flex-flow: column;
      position: absolute;
      background: var(--main-bg-color);
      border-radius: 12px;
      padding-left: 3px;
      z-index: 2000;
    }
    div.format-options:hover {
      cursor: pointer;
      border: 3px solid var(--kbd-border-color);
      padding: 3px;
      transform: translate(-3px, -6px);
    }
    div.format-options .format-option {
      display: none;
    }
    div.format-options:hover .format-option {
      display: inline-block;
    }
    .format-option:not(.selected) {
      margin-top: 3px;
    }
    div.format-options .format-option.selected {
      order: -1;
      display: inline-block;
    }
    .format-option:hover {
      background-color: var(--kbd-border-color);
    }
    span.config-value {
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
    .label {
      user-select: none;
    }
    .label:hover span.config-value {
      display: inline-block;
      min-width: 150px;
    }
    .clipboard-span.matching-config .label {
      color: var(--cm-macro-color);
      font-weight: bold;
    }
    .clipboard-span.different-config .label {
      color: var(--cm-tag-color);
      font-weight: bold;
    }
  `
export function addContainerStyle(CONTAINER) {
  CONTAINER.classList.add(CONTAINER_STYLE);
}