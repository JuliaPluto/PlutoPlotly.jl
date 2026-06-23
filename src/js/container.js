// Pluto-agnostic construction of the plot container.
// Creates the `.plutoplotly-container` element and its child plot div, and
// stashes the Plotly handle + PLOT div on the container so later code can read
// them from CONTAINER rather than from shared globals. Only the DOM structure
// lives here; the per-run lifecycle (AbortController, @bind listener, style,
// invalidation) stays with the caller for now (see src/main_struct.jl).
function makeContainer(Plotly, html) {
  const CONTAINER = html`<div class='plutoplotly-container'></div>`;
  CONTAINER.Plotly = Plotly;
  CONTAINER.PLOT = CONTAINER.appendChild(html`<div></div>`);
  return CONTAINER;
}
