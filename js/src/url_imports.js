// We put all url imports here to have them in a single place
import createEmotion from "https://esm.sh/@emotion/css@11.11.2/create-instance";
import lodash from "https://esm.sh/lodash-es@4.17.21";
import { html } from "https://esm.sh/gh/observablehq/stdlib@v5.8.6/src/html.js";
import { default as interact } from "https://esm.sh/interactjs@1.10.26"

// We need to create our custom emotion instance while loading the module to avoid 
const emotion = createEmotion(
  {
    key: 'css',
    container: globalThis.document,
  }
);

export const css = emotion.css
export { createEmotion, emotion, html, lodash, interact }