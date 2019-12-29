// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import { Elm } from "../src/Main.elm";

const LOCALHOST_URI = "http://localhost:4000";
const PROD_URI = "http://localhost:4000";
const API_ROOT_URI = process.env.NODE_ENV === "development" ? LOCALHOST_URI : PROD_URI;

const app = Elm.Main.init({
  node: document.getElementById('elm-main'),
  flags: { apiRootUrl: API_ROOT_URI }
});
