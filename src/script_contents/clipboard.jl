const clipboard_script = htl_js("""
// We create a Promise version of setTimeout
function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getImageOptions() {
  const o = plot_obj.config.toImageButtonOptions ?? {};
  return {
    format: o.format ?? "png",
    width: o.width ?? original_width,
    height: o.height ?? original_height,
    scale: o.scale ?? 1,
    filename: "newplot",
  };
}

const CLIPBOARD_HEADER =
  CONTAINER.querySelector(".plutoplotly-clipboard-header") ??
  CONTAINER.insertAdjacentElement(
    "afterbegin",
    html`<div class="plutoplotly-clipboard-header hidden">
      <span class="clipboard-span format"
        ><span class="label">Format:</span
        ><span class="clipboard-value format"></span
      ></span>
      <span class="clipboard-span width"
        ><span class="label">Width:</span
        ><span class="clipboard-value width"></span>px</span
      >
      <span class="clipboard-span height"
        ><span class="label">Height:</span
        ><span class="clipboard-value height"></span>px</span
      >
      <span class="clipboard-span scale"
        ><span class="label">Scale:</span
        ><span class="clipboard-value scale"></span
      ></span>
      <button class="clipboard-span set">Set</button>
      <button class="clipboard-span unset">Unset</button>
      <span class="clipboard-span filename"
        ><span class="label">Filename:</span
        ><span class="clipboard-value filename"></span
      ></span>
    </div>`
  );

function checkConfigSync(container) {
  const valid_classes = ['missing-config','matching-config','different-config']
  function setClass(cl) {
    for (const name of valid_classes) {
      container.classList.toggle(name, name == cl)
    }
  }
  // We use the custom getters we'll set up in the container
  const {ui_value, config_value, config_span, key} = container
  if (config_value === undefined) {
    setClass('missing-config')
      config_span.innerHTML = `The key <b><em>\${key}</em></b> is not present in the config.`
    } else if (ui_value == config_value) {
      setClass('matching-config')
      config_span.innerHTML = `The key <b><em>\${key}</em></b> has the same value in the config and in the header.`
    } else {
      setClass('different-config')
      config_span.innerHTML = `The key <b><em>\${key}</em></b> has a different value (<em>\${config_value}</em>) in the config.`
  }
  // Add info about setting and unsetting
  config_span.insertAdjacentHTML("beforeend", `<br>Click on the label <em><b>once</b></em> to set the current UI value in the config.`)
  config_span.insertAdjacentHTML("beforeend", `<br>Click <em><b>twice</b></em> to remove this key from the config.`)
}

const valid_formats = ["png", "svg", "webp", "jpeg", "full-json"];
function initializeUIValueSpan(span, key, value) {
  const container = span.closest(".clipboard-span");
  span.contentEditable = key === "format" ? "false" : "true";
  let parse = (x) => x;
  let update = (x) => (span.textContent = x);
  if (key === "width" || key === "height") {
    parse = (x) => Math.round(parseFloat(x));
  } else if (key === "scale") {
    parse = parseFloat;
  } else if (key === "format") {
    // We remove contentEditable
    span.contentEditable = "false";
    // Here we first add the subspans for each option
    const opts_div = span.appendChild(html`<div class="format-options"></div>`);
    for (const fmt of valid_formats) {
      const opt = opts_div.appendChild(
        html`<span class="format-option \${fmt}">\${fmt}</span>`
      );
      opt.onclick = (e) => {
        span.value = opt.textContent;
      };
    }
    parse = (x) => {
      return valid_formats.includes(x) ? x : localValue;
    };
    update = (x) => {
      for (const opt of opts_div.children) {
        opt.classList.toggle("selected", opt.textContent === x);
      }
    };
  } else {
    // We only have filename here
  }
  let localValue;
  Object.defineProperty(span, "value", {
    get: () => {return localValue},
    set: (val) => {
      if (val !== "") {
        localValue = parse(val);
      }
      update(localValue);
      checkConfigSync(container)
    },
  });
  // We also assign a listener so that the editable is blurred when enter is pressed
  span.onkeydown = (e) => {
    if (e.keyCode === 13) {
      e.preventDefault();
      span.blur();
    }
  };
  span.value = value;
}


function initializeConfigValueSpan(span, key) {
  // Here we mostly want to define the setter and getter
  const container = span.closest('.clipboard-span')
  Object.defineProperty(span, "value", {
    get: () => {
      return plot_obj.config.toImageButtonOptions[key]
    },
    set: (val) => {
      // if undefined is passed, we remove the entry from the options
      if (val === undefined) {
        delete plot_obj.config.toImageButtonOptions[key]
      } else {
        plot_obj.config.toImageButtonOptions[key] = val
      }
      checkConfigSync(container)
    }
  })
}

const config_spans = {};
for (const [key, value] of Object.entries(getImageOptions())) {
  const container = CLIPBOARD_HEADER.querySelector(`.clipboard-span.\${key}`);
  const label = container.querySelector('.label')
  // We give the label a function that on single click will set the current value and with double click will unset it
  label.onclick = DualClick(() => {
    container.config_value = container.ui_value
  }, (e) => {
    console.log('e', e)
    e.preventDefault()
    container.config_value = undefined
  })
  const ui_value_span = container.querySelector(".clipboard-value");
  const config_value_span =
    container.querySelector(".config-value") ??
    label.insertAdjacentElement(
      "afterbegin",
      html`<span class="config-value"></span>`
    );
  // Assing the two spans as properties of the containing span
  container.ui_span = ui_value_span
  container.config_span = config_value_span
  container.key = key
  config_spans[key] = container;
  if (firstRun) {
    plot_obj.config.toImageButtonOptions = plot_obj.config.toImageButtonOptions ?? {}
    // We do the initialization of the value span
    initializeUIValueSpan(ui_value_span, key, value);
    // Then we initialize the config value
    initializeConfigValueSpan(config_value_span, key);
    // We put some convenience getters/setters
    // ui_value forward
    Object.defineProperty(container, "ui_value", {
      get: () => ui_value_span.value,
      set: (val) => {ui_value_span.value = val}
    })
    // config_value forward
    Object.defineProperty(container, "config_value", {
      get: () => config_value_span.value,
      set: (val) => {config_value_span.value = val}
    })
  }
}

// These objects will contain the default value

// This code updates the image options in the PLOT config with the provided ones
function setImageOptions(o) {
  for (const [key, container] of Object.entries(config_spans)) {
    container.config_value = o[key];
  }
}
function unsetImageOptions() {
  setImageOptions({})
}

const set_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.set");
const unset_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.unset");
if (firstRun) {
  set_button.onclick = (e) => {
    for (const container of Object.values(config_spans)) {
      container.config_value = container.ui_value
    }
  }
  unset_button.onclick = unsetImageOptions
}

// We add a function to check if the clipboard is popped out
CONTAINER.isPoppedOut = () => {
  return CONTAINER.classList.contains("popped-out");
};

CLIPBOARD_HEADER.onmousedown = function (event) {
  if (event.target.matches("span.clipboard-value")) {
    console.log("We don't move!");
    return;
  }
  const start = {
    left: parseFloat(CONTAINER.style.left),
    top: parseFloat(CONTAINER.style.top),
    X: event.pageX,
    Y: event.pageY,
  };
  function moveAt(event, start) {
    const top = event.pageY - start.Y + start.top + "px";
    const left = event.pageX - start.X + start.left + "px";
    CLIPBOARD_HEADER.style.left = left;
    CONTAINER.style.left = left;
    CONTAINER.style.top = top;
  }

  // move our absolutely positioned ball under the pointer
  moveAt(event, start);
  function onMouseMove(event) {
    moveAt(event, start);
  }

  // We use this to remove the mousemove when clicking outside of the container
  const controller = new AbortController();

  // move the container on mousemove
  document.addEventListener("mousemove", onMouseMove, {
    signal: controller.signal,
  });
  document.addEventListener(
    "mousedown",
    (e) => {
      if (e.target.closest(".plutoplotly-container") !== CONTAINER) {
        cleanUp();
        controller.abort();
        return;
      }
    },
    { signal: controller.signal }
  );

  function cleanUp() {
    console.log("cleaning up the plot move listener");
    controller.abort();
    CLIPBOARD_HEADER.onmouseup = null;
  }

  // (3) drop the ball, remove unneeded handlers
  CLIPBOARD_HEADER.onmouseup = cleanUp;
};

function sendToClipboard(blob) {
  if (!navigator.clipboard) {
    alert(
      "The Clipboard API does not seem to be available, make sure the Pluto notebook is being used from either localhost or an https source."
    );
  }
  navigator.clipboard
    .write([
      new ClipboardItem({
        // The key is determined dynamically based on the blob's type.
        [blob.type]: blob,
      }),
    ])
    .then(
      function () {
        console.log("Async: Copying to clipboard was successful!");
      },
      function (err) {
        console.error("Async: Could not copy text: ", err);
      }
    );
}

function copyImageToClipboard() {
  // We extract the image options from the provided parameters (if they exist)
  const config = {}
  for (const [key, container] of Object.entries(config_spans)) {
    let val = container.config_value ?? (CONTAINER.isPoppedOut() ? container.ui_value : undefined)
    // If we have undefined we don't create the key. We also ignore format because the clipboard only supports png.
    if (val === undefined || key === 'format') {continue}
    config[key] = val
  }
  Plotly.toImage(PLOT, config).then(function (
    dataUrl
  ) {
    fetch(dataUrl)
      .then((res) => res.blob())
      .then((blob) => sendToClipboard(blob));
  });
}

function saveImageToFile() {
  const config = {}
  for (const [key, container] of Object.entries(config_spans)) {
    let val = container.config_value ?? (CONTAINER.isPoppedOut() ? container.ui_value : undefined)
    // If we have undefined we don't create the key.
    if (val === undefined) {continue}
    config[key] = val
  }
  Plotly.downloadImage(PLOT, config)
}

let container_rect = { width: 0, height: 0, top: 0, left: 0 };
function unpop_container(cl) {
  CONTAINER.classList.toggle("popped-out", false);
  CONTAINER.classList.toggle(cl, false);
  // We fix the height back to the value it had before popout, also setting the flag to signal that upon first resize we remove the fixed inline-style
  CONTAINER.style.height = container_rect.height + "px";
  remove_container_size = true;
  // We set the other fixed inline-styles to null
  CONTAINER.style.width = "";
  CONTAINER.style.top = "";
  CONTAINER.style.left = "";
  // We also remove the CLIPBOARD_HEADER
  CLIPBOARD_HEADER.style.width = "";
  CLIPBOARD_HEADER.style.left = "";
  // Finally we remove the hidden class to the header
  CLIPBOARD_HEADER.classList.toggle("hidden", true);
  return;
}
function popout_container(cl) {
  if (CONTAINER.isPoppedOut()) {
    return unpop_container(cl);
  }
  CONTAINER.classList.toggle(cl, cl === undefined ? false : true)
  // We extract the current size of the container, save them and fix them
  const { width, height, top, left } = CONTAINER.getBoundingClientRect();
  container_rect = { width, height, top, left };
  const pad = {}
  pad.unpopped = getSizeData().container_pad;
  CONTAINER.classList.toggle("popped-out", true);
  pad.popped = getSizeData().container_pad;
  // We do top and left based on the current rect
  for (const key of ['top','left']) {
    let offset = 0
    for (const kind of ['padding','border']) {
      offset += pad.popped[kind][key] - pad.unpopped[kind][key]
    }
    CONTAINER.style[key] = container_rect[key] - offset + "px";
    if (key === 'left') {
      CLIPBOARD_HEADER.style[key] = CONTAINER.style[key];
    }
  }
  // We compute the width and height depending on eventual config data
  const csz = computeContainerSize({
    width: config_spans.width.config_value ?? PLOT._fullLayout.width,
    height: config_spans.height.config_value ?? PLOT._fullLayout.height,
  })
  debugger
  for (const key of ['width','height']) {
    CONTAINER.style[key] = csz[key] + "px";
    if (key === 'width') {
      CLIPBOARD_HEADER.style[key] = CONTAINER.style[key];
    }
  }
  CLIPBOARD_HEADER.classList.toggle("hidden", false);
  const controller = new AbortController();

  document.addEventListener(
    "mousedown",
    (e) => {
      if (e.target.closest(".plutoplotly-container") !== CONTAINER) {
        unpop_container();
        controller.abort();
        return;
      }
    },
    { signal: controller.signal }
  );
}

CONTAINER.popOut = popout_container;

function DualClick(single_func, dbl_func) {
  let nclicks = 0;
  return function (...args) {
    nclicks += 1;
    if (nclicks > 1) {
      dbl_func(...args);
      nclicks = 0;
    } else {
      delay(300).then(() => {
        if (nclicks == 1) {
          single_func(...args);
        }
        nclicks = 0;
      });
    }
  };
}

// We remove the default download image button
plot_obj.config.modeBarButtonsToRemove = _.union(
  plot_obj.config.modeBarButtonsToRemove,
  ["toImage"]
);
// We add the custom button to the modebar
plot_obj.config.modeBarButtonsToAdd = _.union(
  plot_obj.config.modeBarButtonsToAdd,
  [
    {
      name: "Copy PNG to Clipboard",
      icon: {
        height: 520,
        width: 520,
        path: "M280 64h40c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V128C0 92.7 28.7 64 64 64h40 9.6C121 27.5 153.3 0 192 0s71 27.5 78.4 64H280zM64 112c-8.8 0-16 7.2-16 16V448c0 8.8 7.2 16 16 16H320c8.8 0 16-7.2 16-16V128c0-8.8-7.2-16-16-16H304v24c0 13.3-10.7 24-24 24H192 104c-13.3 0-24-10.7-24-24V112H64zm128-8a24 24 0 1 0 0-48 24 24 0 1 0 0 48z",
      },
      direction: "up",
      click: DualClick(copyImageToClipboard, () => {popout_container()}),
    },
    {
      name: "Download Image",
      icon: Plotly.Icons.camera,
      direction: "up",
      click: DualClick(saveImageToFile, () => {popout_container("filesave")}),
    },
  ]
);
""")