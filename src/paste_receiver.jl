"""
    plutoplotly_paste_receiver(;popped = true, top = 42, right = 150, left = missing)
Create a widget that when shown inside a Pluto output generates a container
specifically made for extracting images of exported plots obtained with the
clipboard button on the plotly modebar.

## Keyword Arguments
- `popped`: Flag to decide whether the container will be popped out of the cell \
output. If popped, the container is always floating on the screen, minimized and shown as a \
clipboard icon that can be expanded by hovering over it.
- `top`: Specify the default distance (in px) of the container from the top of \
the window when popped.
- `right`: Specify the default distance (in px) of the container from the right \
of the window when popped.
- `left`: Specify the default distance (in px) of the container from the left of \
the window when popped. If this is provided, the `right` value will be ignored.
"""
function plutoplotly_paste_receiver(;popped = true, top = 42, right = 150, left = missing) 
@htl("""
<script src="https://kit.fontawesome.com/087fc9ff41.js" crossorigin="anonymous"></script>
<paste-receiver class="plutoplotly noimage minimized $(popped ? " popped" : "" )">
  <div class="header">
    <i class="empty"></i>
    <i class="clipboard    fa-regular fa-clipboard"></i>
    <i class="keep-open fa-solid fa-thumbtack"></i>
    <i class="popout fa-solid fa-arrow-up-right-from-square"></i>
    <i class="close fa-solid fa-xmark"></i>
  </div>
  <img />
  <div class="message">
    The plot image will be pasted here as soon as the clipboard button is
    pressed
  </div>
</paste-receiver>
<script>
  const paste_receiver =
    currentScript.parentElement.querySelector("paste-receiver");
  const img = paste_receiver.querySelector("img");
  const clipboard_icon = paste_receiver.querySelector(".clipboard");
  paste_receiver.attachImage = function (data, caller) {
    img.src = data;
    paste_receiver.last_caller = caller;
    paste_receiver.classList.toggle("noimage", false);
    paste_receiver.classList.toggle("hasimage", true);
    // We make the clipboard wobble for half a second
    clipboard_icon.classList.toggle('fa-bounce', true)
    setTimeout(() => {
      clipboard_icon.classList.toggle('fa-bounce', false)
    }, 2000)
  };

  const { default: interact } = await import(
    "https://esm.sh/interactjs@1.10.19"
  );
  const { css } = await import(
    "https://esm.sh/@emotion/css@11.11.2"
  )
  paste_receiver.interact = interact
  paste_receiver.css = css

  function clearPosition(el) {
    for (const key of ["top", "left", "bottom", "right"]) {
      el.style[key] = ""
    }
  }
  function getPosition(el) {
    const p = {}
    for (const key of ["top", "left", "bottom", "right"]) {
      const val = el.style[key]
      if (val === "") {continue}
      p[key] = parseFloat(val)
    }
    return p
  }

  function setPosition(el, p) {
    for (const key of ["top", "left", "bottom", "right"]) {
      if (p[key] === undefined) {continue}
      el.style[key] = p[key]
    }
  }

  paste_receiver.classList.toggle('right-side', $(left isa Missing))
  paste_receiver.classList.toggle('left-side', $(left isa Real))

  function computeViewPortDistances(el) {
    const r = el.getBoundingClientRect()
    const vw = document.body.clientWidth
    const vh = document.body.clientHeight
    const centers_dist = { // This is the distance of the center of el from the center of the viewport
      x: r.left + r.width / 2 - vw / 2,
      y: vh / 2 - (r.top + r.height / 2),
    }
    return {
      top: r.top,
      bottom: vh - r.bottom,
      left: r.left,
      right: vw - r.right,
      centers_dist,
    }
  }

  function popOut() {
    if (paste_receiver.classList.contains('popped')) { return }
    const ps = paste_receiver.popped_position
    const cs = getComputedStyle(paste_receiver)
    // Maybe add width/height
    ps.width = ps.width ?? parseFloat(cs.width)
    ps.height = ps.height ?? parseFloat(cs.height)
    for (const [key, value] of Object.entries(ps)) {
      paste_receiver.style[key] = value + "px"
    }
    paste_receiver.classList.toggle("popped", true);
  }

  function popIn() {
    if (!paste_receiver.classList.contains('popped')) { return }
    const ps = {}
    for (const key of ["top", "left", "width", "height", "right", "bottom"]) {
      const val = paste_receiver.style[key]
      if (val === '') { continue }
      ps[key] = parseFloat(paste_receiver.style[key])
      paste_receiver.style[key] = ""
    }
    paste_receiver.popped_position = ps
    paste_receiver.classList.toggle("popped", false);
  }

  paste_receiver.popToggle = function (force = !paste_receiver.classList.contains('popped')) {
    return force ? popOut() : popIn()
  }

  function updateSide(d) {
    const c = d.centers_dist
    paste_receiver.style.setProperty("--vertical-edge-distance", d.top + 'px')
    // Update the centers distance
    let dist
    if (c.x > 0) {
      // We are on the right side
      paste_receiver.classList.toggle('left-side', false)
      paste_receiver.classList.toggle('right-side', true)
      dist = d.right
    } else {
      paste_receiver.classList.toggle('left-side', true)
      paste_receiver.classList.toggle('right-side', false)
      dist = d.left
    }
    paste_receiver.style.setProperty("--horizontal-edge-distance", dist + 'px')
  }

  function initialize_interact() {
    let ViewPortDist;
    interact("paste-receiver.popped > .header")
      .draggable({
        listeners: {
          start(event) {
            ViewPortDist = computeViewPortDistances(paste_receiver)
          },
          move(event) {
            ViewPortDist.top += event.dy
            ViewPortDist.left += event.dx
            ViewPortDist.bottom -= event.dy
            ViewPortDist.right -= event.dx
            ViewPortDist.centers_dist.x += event.dx
            ViewPortDist.centers_dist.y -= event.dy
            updateSide(ViewPortDist)
          },
        },
      }).on('doubletap', function (e) {
        paste_receiver.classList.toggle('minimized')
      })


    interact('paste-receiver.popped:not(.minimized)')
      .resizable({
        edges: {top: false, bottom: true, left: true, right: true},
        listeners: {
          start: function(event) {
            paste_receiver.resize_position = getPosition(paste_receiver)
            const d = computeViewPortDistances(paste_receiver)
            const e = event.edges
            const fix = {}
            const horz = e.right ? 'left' : 'right'
            fix[horz] = d[horz] + 'px'
            clearPosition(paste_receiver)
            setPosition(paste_receiver, fix)
          },
          move: function (event) {
            Object.assign(paste_receiver.style, {
              width: `\${event.rect.width}px`,
              height: `\${event.rect.height}px`,
            });
          },
          end: function(event) {
            updateSide(computeViewPortDistances(paste_receiver))
            clearPosition(paste_receiver)
            setPosition(paste_receiver, paste_receiver.resize_position)
            paste_receiver.resize_position = undefined
          }
        },
      })

    interact('paste-receiver i.popout').on('tap', function (e) {
      // We skip on right click
      if (e.originalEvent.button == 2) { return }
      paste_receiver.popToggle()
    })
    interact('paste-receiver i.close').on('tap', function (e) {
      // We skip on right click
      if (e.originalEvent.button == 2) { return }
      paste_receiver.popToggle()
    })
    interact('paste-receiver i.keep-open').on('tap', function (e) {
      // We skip on right click
      if (e.originalEvent.button == 2) { return }
      paste_receiver.classList.toggle('minimized');
    })
  }
  initialize_interact()

  // Do the css with emotion

  const myStyle = css`
  & {
    --vertical-edge-distance: $(top)px;
    --horizontal-edge-distance: $(coalesce(left, right))px;
  }

  & > .header {
    height: 30px;
    position: absolute;
    left: 0px;
    top: 0px;
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  &.popped.minimized:not(:hover)>.header {
    height: fit-content;
    width: fit-content;
    position: relative;
  }

  &.plutoplotly {
    display: flex;
    background: var(--main-bg-color);
    border: 3px solid var(--kbd-border-color);
    border-radius: 12px;
    min-height: 200px;
    max-height: 800px;
    align-items: center;
    justify-content: center;
    flex-flow: column;
    position: relative;
    overflow: auto;
  }

  &.plutoplotly.popped {
    z-index: 1000;
    position: fixed;
    width: 600px;
    height: 400px;
    top: var(--vertical-edge-distance)
  }

  &.plutoplotly.popped.right-side {
    right: var(--horizontal-edge-distance);
  }

  &.plutoplotly.popped.left-side {
    left: var(--horizontal-edge-distance);
  }

  &.plutoplotly.popped.minimized:not(:hover) {
    overflow: visible;
    min-height: 0px;
    height: fit-content !important;
    width: fit-content !important;
    border: none;
    background-color: transparent;
  }

  &.plutoplotly.popped.minimized:not(:hover) *:not(.header) {
    display: none;
  }

  &.plutoplotly .header:not(:hover) i {
    visibility: hidden
  }

  &.plutoplotly.popped.minimized:not(:hover) i.clipboard {
    display: block;
    scale: 1.5;
    visibility: visible !important;
    --fa-animation-iteration-count: 2;
  }

  &.noimage>div.noimage,
  &.noimage>img {
    margin: 0 auto;
  }

  &.noimage>img {
    display: none;
  }

  &.hasimage>.message {
    display: none;
  }

  &.hasimage>img {
    display: block;
  }

  & i {
    margin: 10px;
    margin-left: 5px;
    cursor: pointer;
    color: var(--pluto-output-color);
  }

  & i.keep-open,
  & i.close,
  & i.clipboard {
    display: none;
  }

  &.popped i.empty,
  &.popped i.popout {
    display: none;
  }

  &.popped i.keep-open,
  &.popped i.close {
    display: block;
  }

  &.popped.minimized:not(:hover) i.close paste-receiver.popped.minimized:not(:hover) i.keep-open {
    display: none;
  }

  &.popped.minimized:not(:hover) i.clipboard {
    display: block;
  }

  &.right-side i.keep-open {
    order: 2;
  }

  &.minimized i.keep-open {
    transform: rotate(45deg);
  }
  `

  paste_receiver.classList.add(myStyle)

  invalidation.then(() => {
    interact('paste-receiver.popped > .header').unset()
    interact('paste-receiver.popped:not(.minimized)').unset()
    interact('paste-receiver i.popout').unset()
    interact('paste-receiver i.close').unset()
    interact('paste-receiver i.keep-open').unset()
  })
</script>
""")
end