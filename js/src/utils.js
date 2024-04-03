import { lodash as _ } from "./url_imports.js"

// We use lodash for this for compactness
function removeTypedArray(o) {
  return _.isTypedArray(o)
    ? Array.from(o)
    : _.isPlainObject(o)
    ? _.mapValues(o, removeTypedArray)
    : o;
}

export function processPlotObj(plot_obj) {
  return _.update(plot_obj, "layout", removeTypedArray)
}

export function getImageOptions(plot_obj) {
  const o = plot_obj.config.toImageButtonOptions ?? {};
  return {
    format: o.format ?? "png",
    width: o.width ?? original_width,
    height: o.height ?? original_height,
    scale: o.scale ?? 1,
    filename: o.filename ?? "newplot",
  };
}

// We create a Promise version of setTimeout
export function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}