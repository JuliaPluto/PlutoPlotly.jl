import * as esbuild from "npm:esbuild@0.20.2";
// Import the WASM build on platforms where running subprocesses is not
// permitted, such as Deno Deploy, or when running without `--allow-run`.
// import * as esbuild from "https://deno.land/x/esbuild@0.20.2/wasm.js";

// the plugin wants an absolute path for the deno config so we have to compute the directory of this file.
// Pointing to the correct config is needed to use the import map linking the @emotion/css url to the npm version of the package to fix a bug with the library not realizing it is inside a browser otherwise.
import * as path from "https://deno.land/std@0.207.0/path/mod.ts";
const __dirname = path.dirname(path.fromFileUrl(import.meta.url));
const __config = path.join(__dirname, "deno.jsonc");

import { denoPlugins } from "jsr:@luca/esbuild-deno-loader@^0.10.3";
// import { processPlotObj } from "./src/utils.js";

const result = await esbuild.build({
  plugins: [...denoPlugins({configPath: __config})],
  entryPoints: ["./src/prehooks.js"],
  outfile: "./dist/library.esm.min.js",
  bundle: true,
  format: "esm",
  minify: true,
  metafile: true,
  treeShaking: true,
});

Deno.writeTextFile("./dist/meta.json", JSON.stringify(result.metafile))

// console.log(result.metafile);

esbuild.stop();