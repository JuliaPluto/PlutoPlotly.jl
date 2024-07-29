//@ts-check

/**
 * Function to add Drag functionality to the CLIPBOARD_HEADER
 *
 * @param {import("./typedef.js").Container} CONTAINER - Container element
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least interact
 */
export function addDragFunctionality(CONTAINER, deps = CONTAINER.js_deps) {
  const { interact, lodash } = deps;
  const { CLIPBOARD_HEADER, PLOT_PANE } = CONTAINER;
  const limits = { top: { min: 0, max: 0 }, left: { min: 0, max: 0 } };
  let current = { top: 0, left: 0, width: 0, height: 0 };
  let last = { top: 0, left: 0, width: 0, height: 0 };
  // @ts-ignore We assume interact is present
  interact(CLIPBOARD_HEADER).draggable({
    listeners: {
      start(event) {
        console.log(event.type, event.target);
        const { pr, border, header_height } =
          computeContainerPosition(CONTAINER);
        const { top, left, width, height } = pr;
        // The minus 3 is for allowing some distance to the edge
        limits.left = {
          min: border.left + 3,
          max: globalThis.innerWidth - (width + border.right + 3),
        };
        limits.top = {
          min: border.top + header_height + 3,
          max: globalThis.innerHeight - (height + border.bottom + 3),
        };
        current = { top, left, width, height };
        last = { top, left, width, height };
        CLIPBOARD_HEADER.classList.toggle("dragging", true);
      },
      move(event) {
        const left = (current.left += event.dx);
        const top = (current.top += event.dy);
        const new_vals = {
          top: Math.min(Math.max(top, limits.top.min), limits.top.max),
          left: Math.min(Math.max(left, limits.left.min), limits.left.max),
        };
        if (!lodash.isEqual(last, new_vals)) {
          last = { ...new_vals, width: last.width, height: last.height };
          updateContainerPosition(CONTAINER, last);
        }
      },
      end(event) {
        console.log(event.type, event.target);
        CLIPBOARD_HEADER.classList.toggle("dragging", false);
      },
    },
  });
}

export function addResizeFunctionality(CONTAINER) {
  const { interact, lodash } = CONTAINER.js_deps;
  const { ui_values } = CONTAINER.CLIPBOARD_HEADER;
  const limits = {
    top: { min: 0, max: 0 },
    left: { min: 0, max: 0 },
    width: { min: 10, max: 0 },
    height: { min: 10, max: 0 },
  };
  let current = { top: 0, left: 0, width: 0, height: 0 };
  let last = { top: 0, left: 0, width: 0, height: 0 };
  interact(CONTAINER).resizable({
    edges: { top: true, left: true, bottom: true, right: true },
    listeners: {
      start(event) {
        const { edges } = event;
        const { pr, border, header_height } =
          computeContainerPosition(CONTAINER);
        const { top, left, width, height } = pr;
        current = { top, left, width, height };
        last = { top, left, width, height };
        limits.left.min = border.left + 3;
        limits.left.max = pr.left + width - limits.width.min
        limits.top.min = border.top + header_height + 3;
        limits.top.max = pr.top + height - limits.height.min
        limits.width.max = edges.left
          ? pr.right - limits.left.min // We are resizing left
          : edges.right
          ? globalThis.innerWidth - (pr.left + border.right + 3) // We are resizing right
          : width; // This is in case we are not resizing horizontally
        limits.height.max = edges.top 
          ? pr.bottom - limits.top.min
          : edges.bottom
          ? globalThis.innerHeight - (pr.top + border.bottom + 3)
          : height; // This is in case we are not resizing vertically
        CONTAINER.classList.toggle("resizing", true);
      },
      move(event) {
        const { edges, deltaRect } = event;
        current.width += deltaRect.width;
        current.height += deltaRect.height;
        if (edges.left) {
          current.left += deltaRect.left;
        }
        if (edges.top) {
          current.top += deltaRect.top;
        }
        const new_size = {
          left: Math.min(Math.max(current.left, limits.left.min), limits.left.max),
          top: Math.min(Math.max(current.top, limits.top.min), limits.top.max),
          width: Math.min(Math.max(current.width, limits.width.min), limits.width.max),
          height: Math.min(Math.max(current.height, limits.height.min), limits.height.max),
        }
        if (!lodash.isEqual(last, new_size)) {
          last = { ...new_size };
          updateContainerPosition(CONTAINER, last);
          ui_values.width = last.width;
          ui_values.height = last.height;
        }
      },
      end(event) {
        CONTAINER.classList.toggle("resizing", false);
      },
    },
  });
}

/**
 * Computes the position of the CONTAINER and PLOT_PANE elements, as well as current border and header height of the container.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element.
 * @returns {{cr: DOMRect, pr: DOMRect, border: {top: number, right: number, bottom: number, left: number}, header_height: number}}
 */
function computeContainerPosition(CONTAINER) {
  const cr = CONTAINER.getBoundingClientRect();
  const pr = CONTAINER.PLOT_PANE.getBoundingClientRect();
  const header_height = cr.height - pr.height;

  const computedStyle = getComputedStyle(CONTAINER);
  const border = {
    top: parseFloat(computedStyle.getPropertyValue("border-top-width")),
    right: parseFloat(computedStyle.getPropertyValue("border-right-width")),
    bottom: parseFloat(computedStyle.getPropertyValue("border-bottom-width")),
    left: parseFloat(computedStyle.getPropertyValue("border-left-width")),
  };

  return { cr, pr, border, header_height };
}

/**
 * Updates the position of the CONTAINER based on the provided left and top values.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to update.
 * @param {{top: number, left: number, width: number, height: number}} target_plot_position }
 * @param {ReturnType<typeof computeContainerPosition>} [size_data]
 * @return {undefined} the function does not return a value.
 */
export function updateContainerPosition(
  CONTAINER,
  target_plot_position,
  size_data = computeContainerPosition(CONTAINER)
) {
  const tpr = target_plot_position;

  const { cr, pr, border, header_height } = size_data;

  const { PLOT_PANE } = CONTAINER;
  const PLOT_PANE_CONTAINER = PLOT_PANE.parentElement;

  const top_offset = tpr.top - pr.top;
  const left_offset = tpr.left - pr.left;
  const top = cr.top + top_offset;
  const left = cr.left + left_offset;

  CONTAINER.style.setProperty("--element-top", top + "px");
  CONTAINER.style.setProperty("--element-left", left + "px");
  // The 3 belows are to
  CONTAINER.style.setProperty(
    "--max-width-offset",
    tpr.left + border.right + 3 + "px"
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
