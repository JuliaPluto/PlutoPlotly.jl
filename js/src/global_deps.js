// This module will contain an object that has to be populated at run time with external JS dependencies

/** @type {import("./typedef.js").JSDeps} */
// @ts-ignore: Will be populated at runtime
export const GlobalDeps = {};

/**
 * Sets global dependencies for emotion, lodash, interact and html.
 *
 * @param {import("./typedef.js").JSDeps} params - An object containing emotion, lodash, interact and html dependencies.
 * @return {void}
 */
export function setGlobalDeps({ emotion, lodash, interact, html }) {
  GlobalDeps.emotion = emotion;
  GlobalDeps.lodash = lodash;
  GlobalDeps.interact = interact;
  GlobalDeps.html = html;
}

/**
 * Check if the necessary global dependencies are defined.
 *
 * @return {boolean} Whether all the global dependencies are not undefined
 */
export function validGlobalDeps() {
  return (
    GlobalDeps.emotion != undefined &&
    GlobalDeps.lodash != undefined &&
    GlobalDeps.interact != undefined &&
    GlobalDeps.html != undefined
  );
}