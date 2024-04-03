// The type defined here should be picked up by vscode thanks the jsconfig.json as explained in https://stackoverflow.com/questions/45836847/how-to-get-vs-code-to-understand-jsdocs-typedef-across-multiple-files
// Unfortunately this does not seem to work without the explicit import

// Plotly type
/**
 * @typedef {import('https://esm.sh/@types/plotly.js')} Plotly
 */

// resizer.js types
/**
 * @typedef {Object} BasicSizeData
 * @property {number} left - The left offset
 * @property {number} right - The right offset
 * @property {number} top - The top offset
 * @property {number} bottom - The bottom offset
 * @property {number} width - The width of the element
 * @property {number} height - The height of the element
 */

/**
 * @typedef {Object} PaddingBorderData
 * @property {BasicSizeData} padding - The padding data
 * @property {BasicSizeData} border - The border data
 */

/**
 * @typedef {Object} PaddingBorderOffsetData
 * @property {BasicSizeData} padding - The padding data
 * @property {BasicSizeData} border - The border data
 * @property {Object} offset - The offset data
 * @property {number} offset.top - The top offset
 * @property {number} offset.left - The left offset
 */

/**
 * @typedef {Object} SizeData
 * @property {PaddingBorderOffsetData} plot_pad - The padding and border data for the plot
 * @property {DOMRect} plot_rect - The rect data for the plot
 * @property {PaddingBorderData} container_pad - The padding and border data for the container
 * @property {DOMRect} container_rect - The rect data for the container
 */

/**
 * @typedef {Object} ComputedSizeData
 * @property {number} width - The width of the container element
 * @property {number} height - The height of the container element
 * @property {boolean} noChange - A flag specifying whether the provided target size was the same as the current plot size
 */

/**
 * The additional properties and methods attached to the HTML element `el` where the plotly.js plot is created (using `Plotly.react(el, ...plot_data)`)
 * @typedef {Object} PlotProps
 * @property {{
 *    width: number,
 *    height: number,
 * }} layout_size
 */

/**
 * @typedef {Object} ContainerProps
 * @property {Function} isPoppedOut - Returns true if the container is popped out
 * @property {ResizeObserver} resizeObserver - The resizeObserver controlling the resizing of the CONTAINER and PLOT
 * @property {AbortController} controller - The AbortController used to stop all listeners and observers tied to the CONTAINER
 * @property {Plotly} Plotly - The Plotly library used in this Container
 * @property {HTMLElement & PlotProps} PLOT - The child div containint the plotly.js plot
 * @property {Element | null} CLIPBOARD_HEADER - The header containing all the clipboard related config spans
 * @property {*} [value] - The eventual value of the CONTAINER to be used for `@bind` inside Pluto
 */

/**
 * @typedef {ContainerProps & HTMLElement} Container
 */
