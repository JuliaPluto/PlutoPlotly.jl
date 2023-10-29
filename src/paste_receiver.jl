"""
  plutoplotly_paste_receiver(;popped = true)
Create a widget that when shown inside a Pluto output generates a container
specifically made for extracting images of exported plots obtained with the
clipboard button on the plotly modebar.

With `popped` equals to true (default), the widget will be collapsed and
represented by a clipboard icon on the top-right of the screen. When clicked
upon, the container div is expanded and it will contain the last image that has
been sent to the clipboard from a PlutoPlotly plot.
"""
plutoplotly_paste_receiver(;popped = true) = @htl("""
<script src="https://kit.fontawesome.com/087fc9ff41.js" crossorigin="anonymous"></script>
<paste-receiver class="plutoplotly noimage minimized $(popped ? "popped" : "")">
  <div class="header">
    <i class="empty"></i>
    <i class="clipboard fa-regular fa-clipboard"></i>
    <i class="minimize fa-solid fa-down-left-and-up-right-to-center"></i>
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
    clipboard_icon.classList.toggle('animate', true)
    setTimeout(() => clipboard_icon.classList.toggle('animate', false), 1000)
  };

  const { default: interact } = await import(
    "https://esm.sh/interactjs@1.10.19"
  );
  function initialize_interact() {
    paste_receiver.offset = paste_receiver.offset ?? { x: 0, y: 0 };
    const startPosition = { x: 0, y: 0 };
    interact("paste-receiver.popped > .header")
      .draggable({
        listeners: {
          start(event) {
            paste_receiver.offset.y = startPosition.y =
              paste_receiver.offsetTop;
            paste_receiver.offset.x = startPosition.x =
              paste_receiver.offsetLeft;
          },
          move(event) {
            paste_receiver.offset.x += event.dx;
            paste_receiver.offset.y += event.dy;

            paste_receiver.style.top = `min(95vh, \${paste_receiver.offset.y}px`;
            paste_receiver.style.left = `min(95vw, \${paste_receiver.offset.x}px`;
          },
        },
      })
      .on("doubletap", (e) => {
        minimize(e, true)
      });

    function modify_size_position(remove) {
      const keys = ['top','left','width','height']
      const ps = paste_receiver.position_size ?? _.pick(paste_receiver.getBoundingClientRect(), keys)
      const cs = getComputedStyle(paste_receiver)
      for (const key of keys) {
        if (remove) {
          ps[key] = parseFloat(cs[key])
          paste_receiver.style[key] = ""
        } else {
          // We put the style from the saved one
          paste_receiver.style[key] = ps[key] + "px"
        }
      }
      paste_receiver.position_size = ps
    }
    function find_center(el) {
        r = el.getBoundingClientRect()
        return {
            top: r.top + r.height/2,
            left: r.left + r.width/2
        }
    }

    // This function minimizes or expands the plot and handles the offset
    function minimize(evt, force) {
        const current = paste_receiver.classList.contains('minimized')
        if (force == current) {
            // Noting happens, we just return
            return
        }
        const minimized_after = !current
        const r_before = paste_receiver.getBoundingClientRect()
        paste_receiver.classList.toggle('minimized',force)
        const r_after = paste_receiver.getBoundingClientRect()
        // Expanded (e) and Contracted (c) sizes
        const e = minimized_after ? r_before : r_after
        const c = minimized_after ? r_after : r_before
        // We compute the viewport size
        const vw = window.innerWidth
        const vh = window.innerHeight
        // This is the distance from the top of the top-left icon to the top-left of the container
        const dist = {
          top: 17.4,
          left: 15.9,
        }
        const to_right = e.left + e.width/2 > vw/2
        const minimize_icon = paste_receiver.querySelector('.minimize')
        minimize_icon.style.order = to_right ? 1 : -1
        let left
        let top
        if (minimized_after) {
            /*
            We are contracting
            */
           left = to_right ?
           // We have to contracts towards the right, putting the left at the right corner
           e.right - dist.left : 
           e.left + dist.left
           // Top for top we don't care about left and right targets, just top value
           top = e.top + e.height/2 > vh/2 ?
           e.bottom - dist.top : 
           e.top + dist.top
        } else {
            /*
            We are expanding
            */
           left = to_right ?
           // We have to contracts towards the right, putting the left at the right corner
           c.right + dist.left - e.width : 
           c.left - dist.left
           // Top for top we don't care about left and right targets, just top value
           top = e.top + e.height/2 > vh/2 ?
           c.bottom + dist.top - e.height :
           c.top - dist.top
        }
        paste_receiver.style.left = left + 'px'
        paste_receiver.style.top = top + 'px'
    }

    interact('i.minimize').on('tap', function(e) {
        // We skip on right click
        if (e.originalEvent.button == 2) {return}
        minimize(e, true)
    })
    interact('paste-receiver.minimized i.clipboard').on('tap', function(e) {
        // We skip on right click
        if (e.originalEvent.button == 2) {return}
        minimize(e, false)
    })

    interact('paste-receiver.popped:not(.minimized)')
      .resizable({
        edges: { top: true, left: false, bottom: true, right: true },
        listeners: {
          move: function (event) {
            console.log(event)
            Object.assign(paste_receiver.style, {
              width: `\${event.rect.width}px`,
              height: `\${event.rect.height}px`,
            });
          },
        },
      })
      
      interact('i.popout').on('tap', function(e) {
        // We skip on right click
        if (e.originalEvent.button == 2) {return}
        paste_receiver.classList.toggle('popped', true)
        modify_size_position(false)
      })
      interact('i.close').on('tap', function(e) {
        // We skip on right click
        if (e.originalEvent.button == 2) {return}
        modify_size_position(true)
        paste_receiver.classList.toggle('popped', false)
      })
  }
  initialize_interact()

  invalidation.then(() => {
    interact('paste-receiver').unset()
    interact('i.close').unset()
  })
</script>
<style>
  paste-receiver > .header {
    height: 30px;
    position: absolute;
    left: 0px;
    top: 0px;
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  paste-receiver.plutoplotly {
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
  paste-receiver.plutoplotly.popped {
    z-index: 1000;
    position: fixed;
    width: 600px;
    height: 400px;
    right: 165px;
    top: 62px;
  }
  paste-receiver.plutoplotly.popped.minimized {
    overflow: visible;
    min-height: 0px;
    height: 0px !important;
    width: 0px !important;
    border: none;
    background-color: transparent;
  }
  paste-receiver.plutoplotly.popped.minimized .header {
    height: 100%;
  }
  paste-receiver.plutoplotly.popped.minimized *:not(.header) {
    display: none;
  }
  paste-receiver.plutoplotly .header:not(:hover) i {
    visibility: hidden
  }
  paste-receiver.plutoplotly.popped.minimized i.clipboard {
    display: block;
    scale: 1.5;
    transform: translate(-50%, 0);
    visibility: visible !important;
  }
  i.clipboard.animate {
    animation: tilt-shaking 0.2s 0s 6;
  }
  @keyframes tilt-shaking {
    0% { transform: rotate(0deg) translate(-50%, 0); }
    25% { transform: rotate(5deg) translate(-50%, 0); }
    50% { transform: rotate(0eg) translate(-50%, 0); }
    75% { transform: rotate(-5deg) translate(-50%, 0); }
    100% { transform: rotate(0deg) translate(-50%, 0); }
  }
  paste-receiver.noimage > div.noimage,
  paste-receiver.noimage > img {
    margin: 0 auto;
  }
  paste-receiver.noimage > img {
    display: none;
  }
  paste-receiver.hasimage > .message {
    display: none;
  }
  paste-receiver.hasimage > img {
    display: block;
  }
  paste-receiver i {
    margin: 0 5px;
    cursor: pointer;
    color: var(--pluto-output-color);
  }
  paste-receiver.popped i.empty,
  paste-receiver.popped i.popout {
      display: none;
  }
  paste-receiver.popped:not(.minimized) i.clipboard {
      display: none;
  }
  paste-receiver.popped.minimized i.minimize {
      display: none;
  }
  paste-receiver:not(.popped) i.clipboard,
  paste-receiver:not(.popped) i.minimize,
  paste-receiver:not(.popped) i.close {
    display: none;
  }
  .header:hover > i.popout {
    visibility: visible;
  }
</style>
""")