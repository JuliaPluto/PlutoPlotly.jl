// Self-contained ESLint flat config (no npm deps) for the plot-injection scripts.
//
// The core files (html.js, container.js, clipboard.js, resizer.js) plus the
// active adapter (pluto_adapter.js) are read by Julia and concatenated into a
// single <script> that the package injects into the page (see src/show.jl and
// src/main_struct.jl). They share one lexical scope: per-plot state lives on the
// CONTAINER element, and the files call each other's top-level functions. The
// names below are the cross-file + host contract — declaring them keeps
// `no-undef` useful and doubles as the contract a future non-Pluto (e.g. VSCode)
// adapter would have to provide in place of pluto_adapter.js.

const injectedGlobals = {
  // Published data + library (Julia preamble in src/show.jl)
  plot_obj: "readonly",
  Plotly: "readonly",
  plotly_listeners: "readonly",
  js_listeners: "readonly",
  // Container stylesheet, bound in src/main_struct.jl
  css: "readonly",
  // Provided by html.js (or the host); consumed by the other core files
  html: "readonly",
  // Pluto runtime — only pluto_adapter.js touches `invalidation`
  invalidation: "readonly",
  // Core cross-file functions (defined in one core file, called from another)
  makeContainer: "readonly",
  updatePlotData: "readonly",
  addClipboardFunctionality: "readonly",
  addResizeFunctionality: "readonly",
  getOffsetData: "readonly",
  getSizeData: "readonly",
  computeContainerSize: "readonly",
  computePlotSize: "readonly",
  changeContainerSize: "readonly",
  updateFromHeader: "readonly",
};

const browserGlobals = {
  window: "readonly",
  document: "readonly",
  navigator: "readonly",
  console: "readonly",
  alert: "readonly",
  fetch: "readonly",
  setTimeout: "readonly",
  Promise: "readonly",
  Math: "readonly",
  Object: "readonly",
  Set: "readonly",
  parseFloat: "readonly",
  ResizeObserver: "readonly",
  AbortController: "readonly",
  ClipboardItem: "readonly",
  CustomEvent: "readonly",
};

export default [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module", // these scripts use top-level await
      globals: { ...injectedGlobals, ...browserGlobals },
    },
  },
];
