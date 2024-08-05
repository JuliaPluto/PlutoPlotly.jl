import { addFormatConfigStyle, addClipboardHeaderStyle } from "./styles.js";
import { delay, getImageOptions, image_options_defaults } from "./utils.js";
import { mergeDeps } from "./global_deps.js";
import { addDragFunctionality, addResizeFunctionality } from "./resizer.js";
import { computeContainerPosition, updateContainerPosition } from "./resizer.js";

// Download formats
const valid_download_formats = ["png", "svg", "webp", "jpeg", "full-json"];
// toImageOption keys
/** @type {(keyof import("./typedef.js").toImageOptions)[]} */
export const toImageOptionKeys = [
  "format",
  "width",
  "height",
  "scale",
  "filename",
];

// SVG path of the clipboard icon
const clipboard_path = "M280 64h40c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V128C0 92.7 28.7 64 64 64h40 9.6C121 27.5 153.3 0 192 0s71 27.5 78.4 64H280zM64 112c-8.8 0-16 7.2-16 16V448c0 8.8 7.2 16 16 16H320c8.8 0 16-7.2 16-16V128c0-8.8-7.2-16-16-16H304v24c0 13.3-10.7 24-24 24H192 104c-13.3 0-24-10.7-24-24V112H64zm128-8a24 24 0 1 0 0-48 24 24 0 1 0 0 48z"

/**
 * Update the provided container to eventually add a clipboard header and modify the plot_obj.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container to which the clipboard header will be added.
 * @return {undefined} span function does not return a value.
 */
export function addClipboardFunctionality(CONTAINER) {
  // Return if the CLIPBOARD HEADER has been assigned already
  if (CONTAINER.CLIPBOARD_HEADER !== undefined) return;
  // Try adding the clipboard header if not present
  addClipboardHeader(CONTAINER);
  // Add the drag functionality
  addDragFunctionality(CONTAINER);
  // Add the resize functionality
  addResizeFunctionality(CONTAINER);
  // Customize the togglePopout function
  CONTAINER.togglePopout = function (filesave = false) {
    if (CONTAINER.isPoppedOut()) {
      unpopContainer(CONTAINER);
      CONTAINER.classList.toggle("filesave-extras", false);
    } else {
      popContainer(CONTAINER);
      CONTAINER.classList.toggle("filesave-extras", filesave);
    }
  };
  // Modify the plot object to include the buttons
  modifyModebarButtons(CONTAINER);
  // Add the listener for clipboard image
  addClipboardEventListener(CONTAINER)
}

/**
 * Adds a clipboard event listener to the provided container.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container element to add the listener to.
 * @return {void} This function does not return anything.
 */
function addClipboardEventListener(CONTAINER) {
  function listener(/** @type {CustomEvent} */ e) {
    const img = CONTAINER.querySelector("img.clipboard-receiver");
    // @ts-ignore img will be there and src is a property of it
    img.src = e.detail.imgsrc
  }
  CONTAINER.addEventListener("copy-to-clipboard", listener)
}

/**
 * Adds a tooltip listener to the provided config span element.
 *
 * @param {HTMLElement} target - The HTML element which should trigger the tooltip appearance.
 * @param {HTMLElement} tooltip - The tooltip element whose position should be updated while hovering over the target.
 * @param {import("./typedef.js").JSDeps} js_deps - The dependencies object containing the necessary tools for the tooltip listener.
 * @return {void} This function does not return a value.
 */
function addTooltipListener(target, tooltip, js_deps) {
  const { floatingUI } = js_deps;
  const { computePosition, flip, shift, offset } = floatingUI;
  target.onmouseenter = (e) => {
    computePosition(target, tooltip, {
      strategy: "fixed",
      placement: "top-start",
      middleware: [offset(6), flip(), shift()],
    }).then(({ x, y }) => {
      tooltip.style.top = y + "px";
      tooltip.style.left = x + "px";
    });
  };
}

/**
 * Function to add a configuration span element.
 *
 * @param {import("./typedef.js").Container} CONTAINER - Container element for the plot
 * @param {keyof import("./typedef.js").OptionSpansObject} name - lowercase name of the config span
 */
export function addSingleConfigSpan(CONTAINER, name) {
  const { CLIPBOARD_HEADER } = CONTAINER;
  const { html, lodash } = CONTAINER.js_deps;
  const config_span = html`<span class="tooltip"></span>`;
  const label = html`<span class="label tooltip-target"
    >${config_span}${lodash.capitalize(name)}:</span
  >`;
  const ui_span = html`<span class="clipboard-value ${name}"></span>`;
  /** @type {import("./typedef.js").ImageOptionSpan} */
  const container = html` <span class="clipboard-span ${name}">
    ${label} ${ui_span}
  </span>`;
  // Add custom style if span is the format span
  if (name === "format") {
    addFormatConfigStyle(container);
  }
  // Assign the various variables as properties of the container
  container.label = label;
  container.ui_span = ui_span;
  // Initialize the ui_span
  initializeUIValueSpan(ui_span, name);
  container.config_span = config_span;
  // Initialize the config_span
  initializeConfigValueSpan(config_span, name);
  container.key = name;
  CLIPBOARD_HEADER.option_spans[name] = container;
  // Insert the container as a child of the CLIPBOARD_HEADER
  CLIPBOARD_HEADER.appendChild(container);
  // We put some convenience getters/setters
  // ui_value forward
  Object.defineProperty(container, "ui_value", {
    get: () => container.ui_span.value,
    set: (val) => {
      container.ui_span.value = val;
    },
  });
  // config_value forward
  Object.defineProperty(container, "config_value", {
    get: () => container.config_span.value,
    set: (val) => {
      container.config_span.value = val;
    },
  });
  // Add the onclick for setting/unsetting the config
  label.onclick = DualClick(
    (/** @type {Event} */ e) => {
      e.preventDefault();
      container.config_value = container.ui_value;
    },
    (/** @type {Event} */ e) => {
      e.preventDefault();
      container.config_value = undefined;
    }
  );
  // Add the tooltip listener
  addTooltipListener(label, config_span, CONTAINER.js_deps);
  // Add the listener for imageOptions change
  const listener = (/** @type {CustomEvent} */ e) => {
    checkConfigSync(container);
  };
  checkConfigSync(container);
  // @ts-ignore: addEventListener does not support function with CustomEvent as arguments
  container.addEventListener("clipboard-header-change", listener);
  return;
}

/**
 * Add config spans to the CLIPBOARD_HEADER associated to the given CONTAINER.
 *
 * @param {import("./typedef.js").Container} CONTAINER - the Container containing the clipboard header to add config spans to
 * @return {void}
 */
function addOptionSpans(CONTAINER) {
  const { CLIPBOARD_HEADER } = CONTAINER;
  const { html } = CONTAINER.js_deps;
  // @ts-ignore: Will be populated
  CLIPBOARD_HEADER.option_spans = {};
  addSingleConfigSpan(CONTAINER, "format");
  addSingleConfigSpan(CONTAINER, "width");
  addSingleConfigSpan(CONTAINER, "height");
  addSingleConfigSpan(CONTAINER, "scale");
  addHelpIcon(CONTAINER)
  // Add set/unset
  // CLIPBOARD_HEADER.appendChild(
  //   html`<button class="clipboard-span set">Set</button>`
  // );
  // CLIPBOARD_HEADER.appendChild(
  //   html`<button class="clipboard-span unset">Unset</button>`
  // );
  addSingleConfigSpan(CONTAINER, "filename");
}

function addHelpIcon(CONTAINER) {
  const { html } = CONTAINER.js_deps;
  const { CLIPBOARD_HEADER } = CONTAINER;
  const tooltip = html`<div class="tooltip">
  <p>This floating container can be used to modify the plot appearance before copying to the clipboard or downloading the image corresponding to the plot within this container.</p>

  <p>
  <svg viewBox="0 0 520 520" class='plotly-icon'>
  <path d='${clipboard_path}'></path>
  </svg>
  This is the icon to copy the plot to the clipboard (as a png).
  </p>
  </div>`
  const help = html`<div class='help tooltip-target'>
  <svg xmlns="http://www.w3.org/2000/svg" class="ionicon" viewBox="0 0 512 512"><path d="M160 164s1.44-33 33.54-59.46C212.6 88.83 235.49 84.28 256 84c18.73-.23 35.47 2.94 45.48 7.82C318.59 100.2 352 120.6 352 164c0 45.67-29.18 66.37-62.35 89.18S248 298.36 248 324" fill="none" stroke="currentColor" stroke-linecap="round" stroke-miterlimit="10" stroke-width="40"/><circle cx="248" cy="399.99" r="32"/></svg>
  </div>`
  help.appendChild(tooltip)
  addTooltipListener(help, tooltip, CONTAINER.js_deps)
  CLIPBOARD_HEADER.appendChild(help)
}

/**
 * Adds a clipboard header to the given container.
 *
 * @param {import("./typedef.js").Container} CONTAINER - The container to which the clipboard header will be added.
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least html
 * @return {undefined} span function does not return a value.
 */
export function addClipboardHeader(CONTAINER, deps = CONTAINER.js_deps) {
  const { html, lodash } = mergeDeps(deps);
  /** @type {import("./typedef.js").ClipboardHeader} */
  const CLIPBOARD_HEADER = html`<div
    class="plutoplotly-clipboard-header hidden"
  ></div>`;
  CONTAINER.CLIPBOARD_HEADER = CLIPBOARD_HEADER;
  addClipboardHeaderStyle(CLIPBOARD_HEADER);
  // Add the various spans for the UI
  addOptionSpans(CONTAINER);
  // Add the objects collecting ui and config options values
  addImageOptionsObj(CLIPBOARD_HEADER, "ui");
  addImageOptionsObj(CLIPBOARD_HEADER, "config");
  CONTAINER.insertAdjacentElement("afterbegin", CLIPBOARD_HEADER);
  // Insert the listener for the change in width/height
  function size_listener(/** @type {CustomEvent} */ e) {
    const { key, type, value } = e.detail;
    console.log('resize-event')
    if (type !== "ui") return;
    if (!(key === "width" || key === "height")) return;
    const { pr } = computeContainerPosition(CONTAINER);
    const new_target = { 
      width: pr.width,
      height: pr.height,
      top: pr.top,
      left: pr.left
    }
    // Modify the actual key
    new_target[key] = value
    if (lodash.isEqual(pr, new_target)) return
    updateContainerPosition(CONTAINER, new_target);
  }
  CLIPBOARD_HEADER.addEventListener("clipboard-header-change", size_listener, {
    signal: CONTAINER.controller.signal,
  });
  return;
}

/**
 * Check if the ui and config value for a given span are in sync and update the label color (indirectly through css) and hover text accordingly.
 * @param {import("./typedef.js").ImageOptionSpan} span
 */
function checkConfigSync(span) {
  // We use the custom getters we'll set up in the container
  const { ui_value, config_value, config_span, key } = span;
  if (config_value === undefined) {
    span.setAttribute("config", "missing");
    config_span.setVariableText(
      `The key <b><em>${key}</em></b> is not present in the config.`
    );
  } else if (ui_value == config_value) {
    span.setAttribute("config", "matching");
    config_span.setVariableText(
      `The key <b><em>${key}</em></b> has the same value in the config and in the header.`
    );
  } else {
    span.setAttribute("config", "different");
    config_span.setVariableText(
      `The key <b><em>${key}</em></b> has a different value (<em>${config_value}</em>) in the config.`
    );
  }
}

/**
 * Function that returns the parsing function to generate a config value from the UI config span.
 *
 * @param {string} key - The key to determine the type of function to return.
 * @return {function} The function based on the key.
 */
function parseFunction(key) {
  if (key === "width" || key === "height") {
    return (/** @type {string} */ x) => {
      return Math.round(parseFloat(x));
    };
  } else if (key === "scale") {
    return parseFloat;
  } else if (key === "filename") {
    return (/** @type {string} */ x) => {
      return x;
    };
  } else if (key === "format") {
    return (/** @type {string} */ x) => {
      if (!valid_download_formats.includes(x)) {
        throw new Error(
          `Invalid format: ${x}, only the following ones are supported ${valid_download_formats}`
        );
      }
      return x;
    };
  } else {
    throw new Error(`Unknown key: ${key}`);
  }
}

/**
 *
 * @param {string} key
 * @returns {Function}
 */
function updateFunction(key) {
  if (key === "format") {
    /**
     * @this {HTMLElement & {value: string}}
     */
    return function () {
      this.querySelector(".format-options")?.setAttribute(
        "selected",
        this.value
      );
    };
  } else {
    /**
     * @this {HTMLElement & {value: number | string}}
     */
    return function () {
      this.textContent = `${this.value}`;
    };
  }
}

/**
 *
 * @param {import("./typedef.js").UIValueSpan} span
 * @param {keyof import("./typedef.js").OptionSpansObject} key
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least html
 */
function initializeUIValueSpan(span, key, deps = {}) {
  const { html } = mergeDeps(deps);
  span.contentEditable = `${key !== "format"}`;
  span.updateFromValue = updateFunction(key);
  span.parseValue = parseFunction(key);
  // For the format key we have to add the format options
  if (key === "format") {
    // Here we first add the subspans for each option
    const opts_div = span.appendChild(
      html`<div class="format-options" selected="png"></div>`
    );
    for (const fmt of valid_download_formats) {
      const opt = opts_div.appendChild(
        html`<span class="format-option ${fmt}">${fmt}</span>`
      );
      opt.onclick = () => {
        span.value = opt.textContent;
        span.updateFromValue(span.value);
      };
    }
  }
  Object.defineProperty(span, "value", {
    get() {
      return this._value;
    },
    set(val) {
      let parsedVal;
      try {
        parsedVal = this.parseValue(val);
      } catch (e) {
        console.warn(
          `The following error message was thrown while parsing the provided value ${val}:\n\n${e.message}.\n\nIgnoring the provided value`
        );
        parsedVal = this.value;
      }
      if (parsedVal != this.value) {
        this._value = parsedVal;
        this.dispatchEvent(
          new CustomEvent("clipboard-header-change", {
            bubbles: true,
            detail: { key: key, type: "ui", value: parsedVal },
          })
        );
      }
      this.updateFromValue();
    },
  });
  // We set the default value while initializing
  span.value = image_options_defaults[key];
  // We also assign a listener so that the editable is blurred when enter is pressed
  span.onkeydown = (/** @type {KeyboardEvent} */ e) => {
    if (e.key === "Enter") {
      // We don't want to add a newline in the textarea
      e.preventDefault();
      span.blur();
    }
  };
  if (key !== "format") {
    span.onblur = function () {
      this.value = this.textContent;
    };
  }
}

/**
 * Defines a setter and getter for a config value span.
 *
 * @param {import("./typedef.js").ConfigValueSpan} span - The span element to define the setter and getter on
 * @param {keyof import("./typedef.js").toImageOptions} key - The key to access the config value
 * @param {Partial<import("./typedef.js").JSDeps>} [deps] - Global dependencies containing at least html
 */
function initializeConfigValueSpan(span, key, deps = {}) {
  const { html } = mergeDeps(deps);
  // We add the span that will contain the variable text
  const variableText = html`<p></p>`;
  span.appendChild(variableText);
  // Text for setting the config
  span.appendChild(
    html`<p>
      Click on the label <em><b>once</b></em> to set the current UI value in the
      config.
    </p>`
  );
  // Text for unsetting the config
  span.appendChild(
    html`<p>
      Click <em><b>twice</b></em> to remove span key from the config.
    </p>`
  );
  // We add the function to set the text on the config
  span.setVariableText = (x) => {
    variableText.innerHTML = x;
  };
  // Here we mostly want to define the setter and getter
  Object.defineProperty(span, "value", {
    get() {
      return this._value;
    },
    set(val) {
      if (val == this.value) return;
      this._value = val;
      this.dispatchEvent(
        new CustomEvent("clipboard-header-change", {
          bubbles: true,
          detail: { key: key, type: "config", value: val },
        })
      );
    },
  });
}

/**
 *
 * @param {import("./typedef.js").ClipboardHeader} CLIPBOARD_HEADER
 * @param {string} type
 * @param {import("./typedef.js").Container} type
 */
function addImageOptionsObj(CLIPBOARD_HEADER, type) {
  // @ts-ignore: We populate the keys below
  const out = {};
  const header_key = type === "ui" ? "ui_values" : "config_values";
  const value_key = type === "ui" ? "ui_span" : "config_span";
  for (const key of toImageOptionKeys) {
    const span = CLIPBOARD_HEADER.option_spans[key][value_key];
    Object.defineProperty(out, key, {
      get: () => span.value,
      set: (val) => (span.value = val),
      enumerable: true,
    });
  }
  // @ts-ignore: We did put the keys above
  CLIPBOARD_HEADER[header_key] = out;
}

// // span code updates the image options in the PLOT config with the provided ones
// function setImageOptions(o) {
//   for (const [key, container] of Object.entries(option_spans)) {
//     container.config_value = o[key];
//   }
// }
// function unsetImageOptions() {
//   setImageOptions({});
// }

// const set_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.set");
// const unset_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.unset");
// if (firstRun) {
//   set_button.onclick = (e) => {
//     for (const container of Object.values(option_spans)) {
//       container.config_value = container.ui_value;
//     }
//   };
//   unset_button.onclick = unsetImageOptions;
// }

// CLIPBOARD_HEADER.onmousedown = function (event) {
//   if (event.target.matches("span.clipboard-value")) {
//     console.log("We don't move!");
//     return;
//   }
//   const start = {
//     left: parseFloat(CONTAINER.style.left),
//     top: parseFloat(CONTAINER.style.top),
//     X: event.pageX,
//     Y: event.pageY,
//   };
//   function moveAt(event, start) {
//     const top = event.pageY - start.Y + start.top + "px";
//     const left = event.pageX - start.X + start.left + "px";
//     CLIPBOARD_HEADER.style.left = left;
//     CONTAINER.style.left = left;
//     CONTAINER.style.top = top;
//   }

//   // move our absolutely positioned ball under the pointer
//   moveAt(event, start);
//   function onMouseMove(event) {
//     moveAt(event, start);
//   }

//   // We use span to remove the mousemove when clicking outside of the container
//   const controller = new AbortController();

//   // move the container on mousemove
//   document.addEventListener("mousemove", onMouseMove, {
//     signal: controller.signal,
//   });
//   document.addEventListener(
//     "mousedown",
//     (e) => {
//       if (e.target.closest(".plutoplotly-container") !== CONTAINER) {
//         cleanUp();
//         controller.abort();
//         return;
//       }
//     },
//     { signal: controller.signal }
//   );

//   function cleanUp() {
//     console.log("cleaning up the plot move listener");
//     controller.abort();
//     CLIPBOARD_HEADER.onmouseup = null;
//   }

//   // (3) drop the ball, remove unneeded handlers
//   CLIPBOARD_HEADER.onmouseup = cleanUp;
// };

/**
 * Function to send the provided blob to the clipboard using the Clipboard API.
 *
 * @param {Blob} blob - the blob to be copied to the clipboard
 * @return {void}
 */
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

/**
 * Function to copy the image from the parent container to the clipboard.
 * @param {import('./typedef.js').Container} CONTAINER
 */
export function copyImageToClipboard(CONTAINER) {
  // We extract the image options from the provided parameters (if they exist)
  const { Plotly, PLOT, CLIPBOARD_HEADER } = CONTAINER;
  const { ui_values, config_values } = CLIPBOARD_HEADER;
  const config = {
    width: config_values.width ?? ui_values.width,
    height: config_values.height ?? ui_values.height,
    format: config_values.format ?? ui_values.format,
    scale: config_values.scale ?? ui_values.scale,
  };
  // @ts-ignore config would like toImageOpts but we are ok with this
  Plotly.toImage(PLOT, config).then(function (dataUrl) {
    fetch(dataUrl)
      .then((res) => res.blob())
      .then((blob) => {
        PLOT.dispatchEvent(
          new CustomEvent("copy-to-clipboard", {
            bubbles: true,
            detail: { imgsrc: dataUrl },
          })
        );
        sendToClipboard(blob);
      });
  });
}

/**
 * Function to save the image from the provided container to the disk.
 * @param {import('./typedef.js').Container} CONTAINER
 */
function saveImageToFile(CONTAINER) {
  // We extract the image options from the provided parameters (if they exist)
  const { Plotly, PLOT, CLIPBOARD_HEADER } = CONTAINER;
  const config = CLIPBOARD_HEADER.ui_values;
  // @ts-ignore config would like downloadImageOpts but we just use our own type
  Plotly.downloadImage(PLOT, config);
}

/**
 * Function to pop out the container from the current position to a fixed one.
 *
 * @param {import("./typedef.js").Container} CONTAINER - Main container of the plutoplotly plot
 */
export function popContainer(CONTAINER) {
  // We save the plot pane position before popping it out (which adds border)
  const plot_rect = CONTAINER.PLOT_PANE.getBoundingClientRect();
  CONTAINER.classList.toggle("popped-out", true);
  // We update the left/bottom position to make it fixed in the same position it had before popping
  updateContainerPosition(CONTAINER, plot_rect);
}

/**
 * Function to unpop the container from the fixed position.
 *
 * @param {import("./typedef.js").Container} CONTAINER - Main container of the plutoplotly plot
 */
export function unpopContainer(CONTAINER) {
  CONTAINER.classList.toggle("popped-out", false);
}

/**
 * Creates a function that will execute single_func if clicked once, and dbl_func if clicked twice within a short timeframe.
 *
 * @param {Function} single_func - The function to be executed on a single click
 * @param {Function} dbl_func - The function to be executed on a double click
 * @return {Function} A new function that handles single and double clicks
 */
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


function modifyModebarButtons(CONTAINER) {
  const { plot_obj, js_deps, togglePopout, Plotly } = CONTAINER;
  const { lodash } = js_deps;
  plot_obj.config = plot_obj.config ?? {};
  // We remove the default download image button
  plot_obj.config.modeBarButtonsToRemove = lodash.union(
    plot_obj.config?.modeBarButtonsToRemove,
    ["toImage"]
  );
  // We add the custom button to the modebar
  plot_obj.config.modeBarButtonsToAdd = lodash.union(
    plot_obj.config.modeBarButtonsToAdd,
    [
      {
        name: "Copy PNG to Clipboard",
        icon: {
          height: 520,
          width: 520,
          path: clipboard_path,
        },
        direction: "up",
        click: DualClick(
          () => copyImageToClipboard(CONTAINER),
          () => {
            togglePopout();
          }
        ),
      },
      {
        name: "Download Image",
        icon: Plotly.Icons.camera,
        direction: "up",
        click: DualClick(
          () => saveImageToFile(CONTAINER),
          () => {
            togglePopout(true);
          }
        ),
      },
    ]
  );
}
