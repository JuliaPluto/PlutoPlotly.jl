const resizer_script = htl_js("""
function getOffsetData(el) {
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
function getSizeData() {
  const data = {
    plot_pad: getOffsetData(PLOT),
    plot_rect: PLOT.getBoundingClientRect(),
    container_pad: getOffsetData(CONTAINER),
    container_rect: CONTAINER.getBoundingClientRect(),
  };
  return data;
}
function computeContainerSize({ width, height }, sizeData = getSizeData()) {
  const computed_size = computePlotSize(sizeData);
  const offsets = computed_size.offsets;

  const plot_data = {
    width: width ?? computed_size.width,
    height: height ?? computed_size.height,
  };

  return {
    width: (width ?? computed_size.width) + offsets.width,
    height: (height ?? computed_size.height) + offsets.height,
    noChange: width == computed_size.width && height == computed_size.height,
  }
}

// This function will change the container size so that the resulting plot will be matching the provided specs
function changeContainerSize({ width, height }, sizeData = getSizeData()) {
  if (!CONTAINER.isPoppedOut()) {
    console.log("Tried to change container size when not popped, ignoring");
    return;
  }

  const csz = computeContainerSize({ width, height }, sizeData);

  if (csz.noChange) {
    console.log("Size is the same as current, ignoring");
    return
  }
  // We are now going to set he width and height of the container
  for (const key of ["width", "height"]) {
    CONTAINER.style[key] = csz[key] + "px";
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
// This function computes the plot size to use for relayout as a function of the container size
function computePlotSize(data = getSizeData()) {
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

// Create the resizeObserver to make the plot even more responsive! :magic:
const resizeObserver = new ResizeObserver((entries) => {
  debugger
  const sizeData = getSizeData();
  const {container_rect, container_pad} = sizeData;
  let plot_size = computePlotSize(sizeData);
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
    width: (CONTAINER.isPoppedOut() ? undefined : original_width) ?? plot_size.width,
    height: (CONTAINER.isPoppedOut() ? undefined : original_height) ?? plot_size.height,
    plutoresize: true,
  };
  Plotly.relayout(PLOT, config).then(() => {
    if (remove_container_size) {
      // This is needed to avoid the first resize upon plot creation to already be without a fixed height
      CONTAINER.style.height = "";
      CONTAINER.style.width = "";
      remove_container_size = false;
    }
  });
});

resizeObserver.observe(CONTAINER);
""")