import * as _ from "https://esm.sh/lodash-es@4.17.21";

/**
 * 
 * @param {Object} o 
 * @param {import("./typedef.js").JSDep_lodash} _ 
 * @returns 
 */
function removeTypedArray(o) {
  return _.isTypedArray(o)
    ? Array.from(o)
    : _.isPlainObject(o)
    ? _.mapValues(o, removeTypedArray)
    : o;
}

/**
 * Process the plot object by removing typed arrays in the layout.
 *
 * @param {import("./typedef.js").PlotObj} plot_obj - The plot object to be processed
 * @return {import("./typedef.js").PlotObj} The processed plot object
 */
export function processPlotObj(plot_obj) {
  return _.update(plot_obj, "layout", removeTypedArray)
}

/**
 * Extract the image export options from the plot_obj.
 *
 * @param {import("./typedef.js").PlotObj} plot_obj - The plot object to be processed
 * @return {{
 *   format: string,
 *   width?: number,
 *   height?: number,
 *   scale: number,
 *   filename: string
 * }} The object containing the export data
 */

export const image_options_defaults = {
  format: "png",
  width: 700,
  height: 400,
  scale: 1,
  filename: "newplot"
}
/**
 * Returns the image options for a given plot object, with default values if not provided.
 *
 * @param {import('./typedef.js').PlotObj} [plot_obj] - the plot object for which to get image options
 * @return {{
 *   format: string,
 *   width: number,
 *   height: number,
 *   scale: number,
 *   filename: string
 * }} the image options with default values if not provided
 */
export function getImageOptions(plot_obj, d = image_options_defaults) {
  const o = plot_obj?.config?.toImageButtonOptions ?? {};
  return {
    format: o.format ?? d.format,
    width: o.width ?? d.width,
    height: o.height ?? d.height,
    scale: o.scale ?? d.scale,
    filename: o.filename ?? d.filename,
  };
}

// We create a Promise version of setTimeout
export function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}