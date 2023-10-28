const clipboard_script = htl_js("""
// We create a Promise version of setTimeout
function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getImageOptions() {
  const o = plot_obj.config.toImageButtonOptions ?? {}
  return {
    format: o.format ?? "png",
    width: o.width ?? original_width,
    height: o.height ?? original_height,
    scale: o.scale ?? 1,
    filename: 'newplot'
  }
}

const CLIPBOARD_HEADER =
  CONTAINER.querySelector(".plutoplotly-clipboard-header") ??
  CONTAINER.insertAdjacentElement(
    "afterbegin",
    html`<div class="plutoplotly-clipboard-header hidden">
      <span class="clipboard-span format"
        ><span class="label">Format:</span><span class="clipboard-value format"></span></span
      >
      <span class="clipboard-span width"
        ><span class="label">Width:</span><span class="clipboard-value width"></span>px</span
      >
      <span class="clipboard-span height"
        ><span class="label">Height:</span><span class="clipboard-value height"></span>px</span
      >
      <span class="clipboard-span scale"
        ><span class="label">Scale:</span><span class="clipboard-value scale"></span
      ></span>
      <button class="clipboard-span copy">Set</button>
      <span class="clipboard-span filename"
        ><span class="label">Filename:</span><span class="clipboard-value filename"></span
      ></span>
    </div>`
  );

const valid_formats = ["png", "svg", "webp", "jpeg", "full-json"];
const value_spans = {};
for (const [key, value] of Object.entries(getImageOptions())) {
  const span = CLIPBOARD_HEADER.querySelector(`.clipboard-value.\${key}`);
  value_spans[key] = span;
  if (firstRun) {
    span.contentEditable = "true";
    let parse = (x) => x
    let update = (x) => span.textContent = x
    if (key === "width" || key === "height") {
      parse = (x) => Math.round(parseFloat(x))
    } else if (key === "scale") {
      parse = parseFloat
    } else if (key === "format") {
      // We remove contentEditable
      span.contentEditable = 'false'
      // Here we first add the subspans for each option
      const opts_div = span.appendChild(html`<div class="format-options"></div>`);
      for (const fmt of valid_formats) {
        const opt = opts_div.appendChild(html`<span class='format-option \${fmt}'>\${fmt}</span>`);
        opt.onclick = (e) => {
          span.value = opt.textContent
        }
      }
      parse = (x) => {
        return valid_formats.includes(x) ? x : localValue
      }
      update = (x) => {
        for (const opt of opts_div.children) {
          opt.classList.toggle("selected", opt.textContent === x);
        }
      }
    } else {
      // We only have filename here
    }
    let localValue;
    Object.defineProperty(span, "value", {
      get: () => localValue,
      set: (val) => {
        if (val !== '') {
          localValue = parse(val);
        } 
        update(localValue);
      },
    });
    // We also assign a listener so that the editable is blurred when enter is pressed
    span.onkeydown = (e) => {
      if (e.keyCode === 13) {
        e.preventDefault();
        span.blur();
      }
    };
  }
  span.value = value
}


// This code updates the image options in the PLOT config with the provided ones
function setImageOptions(o) {
  // Get the current options
  const _o = getImageOptions()
  // Extract the object saved in the PLOT, for eventual modification
  const p = plot_obj.config.toImageButtonOptions ?? {}
  for (const key of Object.keys(_o)) {
    const val = o[key]
    if (val == undefined) {
      continue
    }
    p[key] = val
  }
  syncImageOptions()
}

// This function syncs the imageOptions in the clipboard_header to the ones in the PLOT config
function syncImageOptions() {
  const o = getImageOptions()
  for (const key of Object.keys(o)) {
    value_spans[key].value = o[key]
  }
}

const copy_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.copy");



// We add a function to check if the clipboard is popped out
CONTAINER.isPoppedOut = () => {
  return CONTAINER.classList.contains("popped-out");
};

CLIPBOARD_HEADER.onmousedown = function (event) {
  if (event.target.matches('span.clipboard-value')) {
    console.log("We don't move!")
    return
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
  Plotly.toImage(PLOT, PLOT._context.toImageButtonOptions).then(function (
    dataUrl
  ) {
    fetch(dataUrl)
      .then((res) => res.blob())
      .then((blob) => sendToClipboard(blob));
  });
}

let container_rect = { width: 0, height: 0, top: 0, left: 0 };
function unpop_container() {
  CONTAINER.classList.toggle("popped-out", false);
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
function popout_container() {
  if (CONTAINER.isPoppedOut()) {
    return unpop_container();
  }
  // We extract the current size of the container, save them and fix them
  const { width, height, top, left } = CONTAINER.getBoundingClientRect();
  container_rect = { width, height, top, left };
  for (const [key, val] of Object.entries(container_rect)) {
    CONTAINER.style[key] = val + "px";
  }
  CONTAINER.classList.toggle("popped-out", true);
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

function buttonClick(func) {
  let nclicks = 0;
  return function (gd, ev) {
    nclicks += 1;
    if (nclicks > 1) {
      popout_container();
      nclicks = 0;
    } else {
      delay(300).then(() => {
        if (nclicks == 1) {
          func();
        }
        nclicks = 0;
      });
    }
  };
}

if (firstRun) {
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
      name: "Copy to Clipboard",
      icon: {
        height: 520,
        width: 520,
        path: "M280 64h40c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V128C0 92.7 28.7 64 64 64h40 9.6C121 27.5 153.3 0 192 0s71 27.5 78.4 64H280zM64 112c-8.8 0-16 7.2-16 16V448c0 8.8 7.2 16 16 16H320c8.8 0 16-7.2 16-16V128c0-8.8-7.2-16-16-16H304v24c0 13.3-10.7 24-24 24H192 104c-13.3 0-24-10.7-24-24V112H64zm128-8a24 24 0 1 0 0-48 24 24 0 1 0 0 48z",
      },
      direction: "up",
      click: buttonClick(copyImageToClipboard),
    },
  ]
);
}
""")