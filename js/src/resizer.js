//@ts-check

/**
 * Function to add Drag functionality to the to plot container when it's
 * popped-out, working by dragging from the CLIPBOARD_HEADER.
 * This will not allow the container to go outside of the window boundaries.
 *
 * @param {import("./typedef.js").Container} CONTAINER - Container element
 */
export function addDragFunctionality(CONTAINER) {
  const { interact, lodash } = CONTAINER.js_deps;
  const { CLIPBOARD_HEADER } = CONTAINER;
  // limits contains the min and max limits for the corresponding css properties
  const limits = { top: { min: 0, max: 0 }, left: { min: 0, max: 0 } };
  // current and last will hold the current position, modified while dragging, and the last valid position that was enforced
  let current = { top: 0, left: 0, width: 0, height: 0 };
  let last = { top: 0, left: 0, width: 0, height: 0 };
  // @ts-ignore We assume interact is present
  interact(CLIPBOARD_HEADER).draggable({
    listeners: {
      start(event) {
        const { cr, pr, border, header_height } =
          computeContainerPosition(CONTAINER);
        const { top, left, width, height } = pr;
        // The minus 3 is for allowing some distance to the edge
        limits.left = {
          min: border.left + 3,
          max: globalThis.innerWidth - (cr.width - border.left + 3),
        };
        limits.top = {
          min: border.top + header_height + 3,
          // We use the cr.height - header_height because this is constrainted to the window, while the pr.height (PLOT_PANE) can be bigger and represents the height of the plot itself
          max:
            globalThis.innerHeight -
            (cr.height - border.top - header_height + 3), // top/bottom borders are already included in cr.height
        };
        current = { top, left, width, height };
        last = { top, left, width, height };
        console.log("dragstart: ", { pr, border, header_height, limits, last });
        CONTAINER.classList.toggle("dragging", true);
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
        CONTAINER.classList.toggle("dragging", false);
      },
    },
  });
}

/**
 * Function to add Resize functionality to the to plot container when it's
 * popped-out, working by dragging any of the container edges
 * This will not allow any the container edges to go outside of the window boundaries.
 *
 * @param {import("./typedef.js").Container} CONTAINER - Container element
 */
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
        const { cr, pr, border, header_height } =
          computeContainerPosition(CONTAINER);
        const { top, left, width, height } = pr;
        current = { top, left, width, height };
        last = { top, left, width, height };
        limits.left.min = border.left + 3;
        limits.left.max = pr.left + width - limits.width.min;
        limits.top.min = border.top + header_height + 3;
        // This will limit `top` to the value which will make the container bottom border touch the bottom of the window (minus the margin)
        limits.top.max =
          pr.top + (cr.height - header_height) - limits.height.min;
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
          left: Math.min(
            Math.max(current.left, limits.left.min),
            limits.left.max
          ),
          top: Math.min(Math.max(current.top, limits.top.min), limits.top.max),
          width: Math.min(
            Math.max(current.width, limits.width.min),
            limits.width.max
          ),
          height: Math.min(
            Math.max(current.height, limits.height.min),
            limits.height.max
          ),
        };

        if (!lodash.isEqual(last, new_size)) {
          last = { ...new_size };
          updateContainerPosition(CONTAINER, last);
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
export function computeContainerPosition(CONTAINER) {
  const cr = CONTAINER.getBoundingClientRect();
  const pr = CONTAINER.PLOT_PANE.getBoundingClientRect();

  const computedStyle = getComputedStyle(CONTAINER);
  const border = {
    top: parseFloat(computedStyle.getPropertyValue("border-top-width")),
    right: parseFloat(computedStyle.getPropertyValue("border-right-width")),
    bottom: parseFloat(computedStyle.getPropertyValue("border-bottom-width")),
    left: parseFloat(computedStyle.getPropertyValue("border-left-width")),
  };
  // This does not count the container top border, so it is really just the height of the clipboard_header
  const header_height = pr.top - cr.top - border.top;

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
  const top = Math.max(cr.top + top_offset, 3);
  const left = Math.max(cr.left + left_offset, 3);

  // console.log({border, header_height, tpr, pr, cr})

  // These are the height and width offsets for the container in pixels. We add both borders as we have box-sizing: content-box, which does not include borders in the width
  const height_offset =
    tpr.top - header_height + border.bottom + 3;
  const width_offset = tpr.left + border.right + 3;

  CONTAINER.style.setProperty("--element-top", top + "px");
  CONTAINER.style.setProperty("--element-left", left + "px");
  // The 3 belows are to have some margin between the border and the window edge
  CONTAINER.style.setProperty("--max-width-offset", width_offset + "px");
  CONTAINER.style.setProperty("--max-height-offset", height_offset + "px");

  PLOT_PANE_CONTAINER?.style.setProperty(
    "--max-height-offset",
    height_offset + header_height + "px" // We add the header height becuase that is the height difference between container and PLOT_PANE_CONTAINER
  );

  // We set the actual width and height
  CONTAINER.style.setProperty("--plot-width", tpr.width + "px");
  CONTAINER.style.setProperty("--plot-height", tpr.height + "px");
  CONTAINER.style.setProperty("--element-height", tpr.height + header_height + "px");

  // Update the span
  const { ui_values } = CONTAINER.CLIPBOARD_HEADER;
  ui_values.width = tpr.width;
  ui_values.height = tpr.height;
}
