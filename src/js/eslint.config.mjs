// Self-contained ESLint flat config (no npm deps) for the plot-injection scripts.
//
// clipboard.js and resizer.js are read by Julia and concatenated into a single
// <script> that the package injects into the page (see src/show.jl and
// src/main_struct.jl). They therefore share one lexical scope and rely on names
// defined by the Julia preamble, the Pluto runtime, lodash-es, and each other.
// Declaring those names here keeps `no-undef` useful instead of a wall of false
// positives. This list doubles as the contract a future non-Pluto (e.g. VSCode)
// host would have to provide.

const injectedGlobals = {
  // Julia preamble (src/show.jl + the script blocks in src/main_struct.jl)
  plot_obj: "readonly",
  Plotly: "readonly",
  CONTAINER: "readonly",
  PLOT: "readonly",
  firstRun: "readonly",
  original_width: "readonly",
  original_height: "readonly",
  remove_container_size: "writable", // reassigned by resizer.js / unpop
  // Pluto runtime
  html: "readonly",
  // lodash-es, imported in src/show.jl
  _: "readonly",
  // cross-file (clipboard.js <-> resizer.js)
  CLIPBOARD_HEADER: "readonly",
  config_spans: "readonly",
  getSizeData: "readonly",
  computeContainerSize: "readonly",
  computePlotSize: "readonly",
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
