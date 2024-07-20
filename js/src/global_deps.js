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

/**
 * Merges the given dependencies with the existing global dependencies.
 *
 * @param {Partial<import("./typedef.js").JSDeps>} deps - An object containing the JS dependencies to override.
 * @return {import("./typedef.js").JSDeps} - A new object that contains the defaul global deps with the provided ones overwritten.
 */
export function mergeDeps(deps) {
  return {...GlobalDeps, ...deps}
}