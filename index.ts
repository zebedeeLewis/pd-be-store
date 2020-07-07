
import { Elm } from "./src/Main"

import "./scss/app"

document.addEventListener("DOMContentLoaded", () => {
  let app = Elm.Main.init({
    flags: null,
    node: document.getElementById('root')
  })
})
