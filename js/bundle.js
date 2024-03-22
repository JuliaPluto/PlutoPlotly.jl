import * as esbuild from "npm:esbuild@0.20.2";
// Import the WASM build on platforms where running subprocesses is not
// permitted, such as Deno Deploy, or when running without `--allow-run`.
// import * as esbuild from "https://deno.land/x/esbuild@0.20.2/wasm.js";

import { denoPlugins } from "jsr:@luca/esbuild-deno-loader@^0.10.3";

const result = await esbuild.build({
  plugins: [...denoPlugins()],
  entryPoints: ["prehooks.js"],
  outfile: "prehook.esm.js",
  bundle: true,
  format: "esm",
  minify: true,
  treeShaking: true,
});

console.log(result.outputFiles);

esbuild.stop();