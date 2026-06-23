// Resize behaviour for the plot. The size helpers are pure-ish functions that
// take the CONTAINER explicitly; the stateful part (header onblur wiring + the
// ResizeObserver) is wrapped in addResizeFunctionality so nothing leaks into the
// shared script scope. Reads CONTAINER.CLIPBOARD_HEADER / CONTAINER.config_spans
// (set by clipboard.js); exposes getSizeData / computeContainerSize /
// computePlotSize for clipboard.js.

function getOffsetData(CONTAINER, el) {
  const PLOT = CONTAINER.PLOT;
  let cs = window.getComputedStyle(el, null);
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
    }
  };
  if (el === PLOT) {
    // For the PLOT we also want to take into account the offset
    odata.offset = {
      top: PLOT.offsetParent == CONTAINER ? PLOT.offsetTop : 0,
      left: PLOT.offsetParent == CONTAINER ? PLOT.offsetLeft : 0,
    }
  }
  return odata;
}
function getSizeData(CONTAINER) {
  const PLOT = CONTAINER.PLOT;
  const data = {
    plot_pad: getOffsetData(CONTAINER, PLOT),
    plot_rect: PLOT.getBoundingClientRect(),
    container_pad: getOffsetData(CONTAINER, CONTAINER),
    container_rect: CONTAINER.getBoundingClientRect(),
  };
  return data;
}
function computeContainerSize(CONTAINER, { width, height }, sizeData = getSizeData(CONTAINER)) {
  const computed_size = computePlotSize(CONTAINER, sizeData);
  const offsets = computed_size.offsets;

  return {
    width: (width ?? computed_size.width) + offsets.width,
    height: (height ?? computed_size.height) + offsets.height,
    noChange: width == computed_size.width && height == computed_size.height,
  }
}

// This function will change the container size so that the resulting plot will be matching the provided specs
function changeContainerSize(CONTAINER, { width, height }, sizeData = getSizeData(CONTAINER)) {
  if (!CONTAINER.isPoppedOut()) {
    return;
  }

  const csz = computeContainerSize(CONTAINER, { width, height }, sizeData);

  if (csz.noChange) {
    return
  }
  // We are now going to set he width and height of the container
  for (const key of ["width", "height"]) {
    CONTAINER.style[key] = csz[key] + "px";
  }
}
// We now create the function that will update the plot based on the values specified
function updateFromHeader(CONTAINER) {
  const header_data = {
    height: CONTAINER.config_spans.height.ui_value,
    width: CONTAINER.config_spans.width.ui_value,
  };
  changeContainerSize(CONTAINER, header_data);
}
// This function computes the plot size to use for relayout as a function of the container size
function computePlotSize(CONTAINER, data = getSizeData(CONTAINER)) {
  // Remove Padding
  const { container_pad, plot_pad, container_rect } = data;
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

// Wire the header onblur handlers (first run only) and create the ResizeObserver
// that keeps the plot responsive. Returns the observer so the host adapter can
// disconnect this run's observer on invalidation (it must not be stashed on the
// reused CONTAINER, or a later run would clobber the reference).
function addResizeFunctionality(CONTAINER, firstRun) {
  const { Plotly, PLOT } = CONTAINER;
  // We assign updateFromHeader to the onblur event of width and height
  if (firstRun) {
    for (const container of Object.values(CONTAINER.config_spans)) {
      container.ui_span.onblur = (e) => {
        container.ui_value = container.ui_span.textContent;
        updateFromHeader(CONTAINER);
      };
    }
  }
  // Create the resizeObserver to make the plot even more responsive! :magic:
  const resizeObserver = new ResizeObserver(() => {
    const sizeData = getSizeData(CONTAINER);
    const { container_rect } = sizeData;
    let plot_size = computePlotSize(CONTAINER, sizeData);
    // We save the height in the PLOT object
    PLOT.container_height = container_rect.height;
    // We deal with some stuff if the container is poppped
    CONTAINER.CLIPBOARD_HEADER.style.width = container_rect.width + "px";
    CONTAINER.CLIPBOARD_HEADER.style.left = container_rect.left + "px";
    CONTAINER.config_spans.height.ui_value = plot_size.height;
    CONTAINER.config_spans.width.ui_value = plot_size.width;
    /*
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking.
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
    let config = {
      // If this is popped out, we ignore the original width/height
      width: (CONTAINER.isPoppedOut() ? undefined : CONTAINER.original_width) ?? plot_size.width,
      height: (CONTAINER.isPoppedOut() ? undefined : CONTAINER.original_height) ?? plot_size.height,
      plutoresize: true,
    };
    Plotly.relayout(PLOT, config).then(() => {
      if (CONTAINER.remove_container_size && !CONTAINER.isPoppedOut()) {
        // This is needed to avoid the first resize upon plot creation to already be without a fixed height
        CONTAINER.style.height = "";
        CONTAINER.style.width = "";
        CONTAINER.remove_container_size = false;
      }
    });
  });

  resizeObserver.observe(CONTAINER);
  return resizeObserver;
}
