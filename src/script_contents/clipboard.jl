const clipboard_script = htl_js("""
// We create a Promise version of setTimeout
function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

const CLIPBOARD_HEADER =
  CONTAINER.querySelector(".plutoplotly-clipboard-header") ??
  CONTAINER.insertAdjacentElement(
    "afterbegin",
    html`<div class="plutoplotly-clipboard-header hidden">
      <span class="clipboard-span width"
        >Width: <span class="clipboard-value width"></span>px</span
      >
      <span class="clipboard-span height"
        >Height: <span class="clipboard-value height"></span>px</span
      >
      <span class="clipboard-span scale"
        >Scale:
        <span
          class="clipboard-value scale"
          contenteditable="true"
          style="padding: 0 5px"
          >1</span
        ></span
      >
      <button class="clipboard-span copy">Copy</button>
    </div>`
  );
const value_spans = Object.fromEntries(
  ["width", "height", "scale"].map((key) => {
    return [key, CLIPBOARD_HEADER.querySelector(`.clipboard-value.\${key}`)];
  })
);
const copy_button = CLIPBOARD_HEADER.querySelector(".clipboard-span.copy");

CLIPBOARD_HEADER.onmousedown = function (event) {
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
  moveAt(event.pageX, event.pageY);
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
  remove_container_height = true;
  // We set the other fixed inline-styles to null
  CONTAINER.style.width = "";
  CONTAINER.style.top = "";
  CONTAINER.style.left = "";
  CLIPBOARD_HEADER.classList.toggle("hidden", true);
  return;
}
function popout_container() {
  if (CONTAINER.classList.contains("popped-out")) {
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
// We do add a custom button to the mode bar
plot_obj.config.modeBarButtonsToAdd = [
  {
    name: "Copy PNG to Clipboard",
    icon: {
      height: 520,
      width: 520,
      path: "M280 64h40c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V128C0 92.7 28.7 64 64 64h40 9.6C121 27.5 153.3 0 192 0s71 27.5 78.4 64H280zM64 112c-8.8 0-16 7.2-16 16V448c0 8.8 7.2 16 16 16H320c8.8 0 16-7.2 16-16V128c0-8.8-7.2-16-16-16H304v24c0 13.3-10.7 24-24 24H192 104c-13.3 0-24-10.7-24-24V112H64zm128-8a24 24 0 1 0 0-48 24 24 0 1 0 0 48z",
    },
    direction: "up",
    click: buttonClick(copyImageToClipboard),
  },
];
""")
