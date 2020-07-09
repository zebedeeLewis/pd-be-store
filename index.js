
import { Elm } from "./src/Main"

import "material-components-web-elm/dist/material-components-web-elm.min"

import "./scss/app"
import 'material-design-icons/iconfont/material-icons'

document.addEventListener("DOMContentLoaded", () => {
  let app = Elm.Main.init({
    flags: null,
    node: document.getElementById('root')
  })
})
