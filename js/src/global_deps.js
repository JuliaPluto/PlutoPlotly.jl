// This module will contain an object that has to be populated at run time with external JS dependencies

/** @type {import("./typedef.js").JSDeps} */
// @ts-ignore: Will be populated at runtime
export const libs = {};

/**
 * Sets global dependencies for emotion, lodash, interact and html.
 *
 * @param {import("./typedef.js").JSDeps} params - An object containing emotion, lodash, interact and html dependencies.
 * @return {void}
 */
export function setGlobalDeps({ emotion, lodash, interact, html }) {
  libs.emotion = emotion;
  libs.lodash = lodash;
  libs.interact = interact;
  libs.html = html;
}

/**
 * Check if the necessary global dependencies are defined.
 *
 * @return {boolean} Whether all the global dependencies are not undefined
 */
export function validGlobalDeps() {
  return (
    libs.emotion != undefined &&
    libs.lodash != undefined &&
    libs.interact != undefined &&
    libs.html != undefined
  );
}