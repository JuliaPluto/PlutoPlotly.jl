// Minimal tagged-template DOM helper. Replaces Pluto's injected `html`.
// Declared as `function html` (not `const html`) so it shadows the `html`
// parameter Pluto injects into the script scope instead of throwing
// "already declared". Returns the first element child of the parsed fragment;
// sufficient for the `html`<div …>`` usage in the plot core, not a framework.
//
// `document.importNode(..., true)` is REQUIRED: a <template>'s `.content` lives
// in a separate inert document, so its elements have the wrong `ownerDocument`.
// Plotly's d3 layer then throws "Cannot read properties of null (reading
// 'namespaceURI')" inside Plotly.react. importNode adopts the node into the
// main document (this is what observablehq's / Pluto's `html` does too).
function html(strings, ...vals) {
  const t = document.createElement("template");
  t.innerHTML = strings.reduce((acc, s, i) => acc + String(vals[i - 1]) + s);
  return document.importNode(t.content.firstElementChild, true);
}
