import { Elm } from "./src/Main";

document.addEventListener("DOMContentLoaded", () => {
  let app = Elm.Main.init({
    flags: null,
    node: document.getElementById('root')
  });
});
