const resizer_script = htl_js("""
function getOffsetData(el) {
  let cs = window.getComputedStyle(el, null);
  const odata = {
    paddingX: parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight),
    paddingY: parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom),
    borderX: parseFloat(cs.borderLeftWidth) + parseFloat(cs.borderRightWidth),
    borderY: parseFloat(cs.borderTopWidth) + parseFloat(cs.borderBottomWidth),
  };
  if (el === PLOT) {
    // For the PLOT we also want to take into account the offset
    odata.offsetTop = PLOT.offsetParent == CONTAINER ? PLOT.offsetTop : 0;
    odata.offsetLeft = PLOT.offsetParent == CONTAINER ? PLOT.offsetLeft : 0;
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
// This function will change the container size so that the resulting plot will be matching the provided specs
function changeContainerSize({ width, height }, sizeData = getSizeData()) {
  if (!CONTAINER.isPoppedOut()) {
    console.log("Tried to change container size when not popped, ignoring");
    return;
  }
  const computed_size = computePlotSize(sizeData);
  const offsets = computed_size.offsets;

  const plot_data = {
    width: width ?? computed_size.width,
    height: height ?? computed_size.height,
  };

  if (
    plot_data.width == computed_size.width &&
    plot_data.height == computed_size.height
  ) {
    console.log("Size is the same as current, ignoring");
    return;
  }

  // We are now going to set he width and height of the container
  for (const key of ["width", "height"]) {
    CONTAINER.style[key] = plot_data[key] + offsets[key] + "px";
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
      plot_pad.paddingX +
      plot_pad.borderX +
      plot_pad.offsetLeft +
      container_pad.paddingX +
      container_pad.borderX,
    height:
      plot_pad.paddingY +
      plot_pad.borderY +
      plot_pad.offsetTop +
      container_pad.paddingY +
      container_pad.borderY,
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
  const sizeData = getSizeData();
  const container_rect = sizeData.container_rect;
  let plot_size = computePlotSize(sizeData);
  // We save the height in the PLOT object
  PLOT.container_height = container_rect.height;
  // We deal with some stuff if the container is poppped
  if (CONTAINER.isPoppedOut()) {
    CLIPBOARD_HEADER.style.width = container_rect.width + "px";
    CLIPBOARD_HEADER.style.left = container_rect.left + "px";
    config_spans.height.ui_value = plot_size.height;
    config_spans.width.ui_value = plot_size.width;
  }
  /* 
		The addition of the invalid argument `plutoresize` seems to fix the problem with calling `relayout` simply with `{autosize: true}` as update breaking mouse relayout events tracking. 
		See https://github.com/plotly/plotly.js/issues/6156 for details
		*/
  let config = {
    width: original_width ?? plot_size.width,
    height: original_height ?? plot_size.height,
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