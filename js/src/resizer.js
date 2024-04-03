//@ts-check
/**
 * Retrieves the padding and border information for an HTML element from the compute element style, to be used for resizing the plot container.
 *
 * @param {HTMLElement} el - The element to retrieve offset data for.
 * @return {import("./typedef.js").PaddingBorderData} The object containing padding and border information.
 */
function getOffsetData(el) {
  const cs = globalThis.getComputedStyle(el, null);
  const odata = {
    padding: {
      left: parseFloat(cs.paddingLeft),
      right: parseFloat(cs.paddingRight),
      top: parseFloat(cs.paddingTop),
      bottom: parseFloat(cs.paddingBottom),
      width: parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight),
      height: parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom),
    },
    border: {
      left: parseFloat(cs.borderLeftWidth),
      right: parseFloat(cs.borderRightWidth),
      top: parseFloat(cs.borderTopWidth),
      bottom: parseFloat(cs.borderBottomWidth),
      width: parseFloat(cs.borderLeftWidth) + parseFloat(cs.borderRightWidth),
      height: parseFloat(cs.borderTopWidth) + parseFloat(cs.borderBottomWidth),
    },
  };
  return odata;
}
/**
 * Retrieves relevant data for the size of the CONTAINER and of the its associated PLOT object
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container object.
 * @return {import("./typedef.js").SizeData} The size data for the container and plot.
 */
export function getSizeData(CONTAINER) {
  const { PLOT } = CONTAINER;
  const container_pad = getOffsetData(CONTAINER);
  const plot_pad = {
    ...getOffsetData(PLOT),
    offset: {
      top: PLOT.offsetParent == CONTAINER ? PLOT.offsetTop : 0,
      left: PLOT.offsetParent == CONTAINER ? PLOT.offsetLeft : 0,
    },
  };
  const data = {
    plot_pad,
    plot_rect: PLOT.getBoundingClientRect(),
    container_pad,
    container_rect: CONTAINER.getBoundingClientRect(),
  };
  return data;
}
/**
 * Computes the required size of the CONTAINER based on the target size of the PLOT.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element.
 * @param {Object} targetSize - The target size object.
 * @param {number} [targetSize.width] - The target width of the container.
 * @param {number} [targetSize.height] - The target height of the container.
 * @param {import("./typedef.js").SizeData} currentSizeData - The current size data object.
 * @return {{
 *   width: number,
 *   height: number,
 *   noChange: boolean
 * }} The computed size object.
 */
function computeContainerSize(CONTAINER, targetSize = {}, currentSizeData = getSizeData(CONTAINER)) {
  const computed_size = computePlotSize(currentSizeData);
  const offsets = computed_size.offsets;

  const width = (targetSize.width ?? computed_size.width) + offsets.width
  const height = (targetSize.height ?? computed_size.height) + offsets.height
  const noChange = targetSize.width === undefined && targetSize.height === undefined

  return {
    width,
    height,
    noChange,
  };
}

/**
 * Changes the size of the CONTAINER based on the provided target size.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element.
 * @param {Object} targetSize - The target size object.
 * @param {number} [targetSize.width] - The target width of the container.
 * @param {number} [targetSize.height] - The target height of the container.
 * @param {import("./typedef.js").SizeData} currentSizeData - The current size data object.
 */
function changeContainerSize(
  CONTAINER,
  targetSize,
  currentSizeData
) {
  if (!CONTAINER.isPoppedOut()) {
    console.log("Tried to change container size when not popped, ignoring");
    return;
  }

  const csz = computeContainerSize(CONTAINER, targetSize, currentSizeData);

  if (csz.noChange) {
    console.log("Size is the same as current, ignoring");
    return;
  }
  // We are now going to set he width and height of the container
  for (const key of ["width", "height"]) {
    CONTAINER.style.setProperty(key, csz[key] + "px");
  }
}
// We now create the function that will update the plot based on the values specified
function updateFromHeader() {
  const header_data = {
    height: config_spans.height.ui_value,
    width: config_spans.width.ui_value,
  };
  changeContainerSize(header_data);
}
// We assign this function to the onblur event of width and height
if (firstRun) {
  for (const container of Object.values(config_spans)) {
    container.ui_span.onblur = (e) => {
      container.ui_value = container.ui_span.textContent;
      updateFromHeader();
    };
  }
}
// This function computes 
/**
 * Computes the plot size to use for relayout as a function of the container size.
 *
 * @param {import("./typedef.js").SizeData} sizeData - The current size data object.
 */
function computePlotSize(sizeData) {
  // Remove Padding
  const { container_pad, plot_pad, container_rect } = sizeData;
  const offsets = {
    width:
      plot_pad.padding.width +
      plot_pad.border.width +
      plot_pad.offset.left +
      container_pad.padding.width +
      container_pad.border.width,
    height:
      plot_pad.padding.height +
      plot_pad.border.height +
      plot_pad.offset.top +
      container_pad.padding.height +
      container_pad.border.height,
  };
  const sz = {
    width: Math.round(container_rect.width - offsets.width),
    height: Math.round(container_rect.height - offsets.height),
    offsets,
  };
  return sz;
}

// Create the resizeObserver to make the plot even more responsive! :magic:
/**
 * Computes the required size of the CONTAINER based on the target size of the PLOT.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element.
 * @param {import("./typedef.js").Plotly} Plotly - The Plotly library.
 */
export function addResizeObserver(CONTAINER) {
const resizeObserver = new ResizeObserver(() => {
  const sizeData = getSizeData(CONTAINER);
  const { PLOT, CLIPBOARD_HEADER, Plotly } = CONTAINER
  const { container_rect } = sizeData;
  const plot_size = computePlotSize(sizeData);
  // We save the height in the PLOT object
  PLOT.container_height = container_rect.height;
  // We deal with some stuff if the container is poppped
  CLIPBOARD_HEADER.style.width = container_rect.width + "px";
  CLIPBOARD_HEADER.style.left = container_rect.left + "px";
  config_spans.height.ui_value = plot_size.height;
  config_spans.width.ui_value = plot_size.width;
  /* 
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking. 
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
  let config = {
    // If this is popped out, we ignore the original width/height
    width:
      (CONTAINER.isPoppedOut() ? undefined : original_width) ?? plot_size.width,
    height:
      (CONTAINER.isPoppedOut() ? undefined : original_height) ??
      plot_size.height,
    plutoresize: true,
  };
  Plotly.relayout(PLOT, config).then(() => {
    if (remove_container_size && !CONTAINER.isPoppedOut()) {
      // This is needed to avoid the first resize upon plot creation to already be without a fixed height
      CONTAINER.style.height = "";
      CONTAINER.style.width = "";
      remove_container_size = false;
    }
  });
});
  resizeObserver.observe(CONTAINER);
  // Save the resizer inside the CONTAINER
  CONTAINER.resizeObserver = resizeObserver;
}

