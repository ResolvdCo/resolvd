// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

import Trix from "./hooks/trix";

let Hooks = {}

Hooks.DisplayMessage = {
  mounted() {
    this.el.addEventListener("load", event => {
      event.target.style.height = `${event.target.contentWindow.document.body.scrollHeight}px`
      event.target.style.width = `${event.target.contentWindow.document.body.scrollWidth}px`
      let scrollingHeight = event.target.contentWindow.document.scrollingElement.scrollHeight
      let scrollingWidth = event.target.contentWindow.document.scrollingElement.scrollWidth

      if (event.target.style.height != scrollingHeight) {
        event.target.style.height = `${scrollingHeight}px`
      }

      if (event.target.style.width != scrollingWidth) {
        event.target.style.width = `${scrollingWidth}px`
      }
    })
  }
}

Hooks.Trix = Trix

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// window.addEventListener("phx:input", event => {
//   event.target.style.height = '10px';
//   event.target.style.height = `${event.target.scrollHeight + 2}px`;
// })

// window.addEventListener("phx:highlight", event => {
//   let conversation = document.getElementById(event.detail.id)
//   if (conversation) {
//     conversation.classList.remove("hover:bg-gradient-to-r", "hover:border-x-red-100")
//     conversation.classList.add("bg-gradient-to-r", "border-x-red-500")

//     let name = conversation.querySelector("h1")
//     name.classList.remove("text-gray-700")
//     name.classList.add("text-gray-800")

//     let subject = conversation.querySelector("p")
//     subject.classList.remove("text-gray-600")
//     subject.classList.add("text-gray-700")
//   }
// })


// window.addEventListener("phx:remove-highlight", event => {
//   let conversation = document.getElementById(event.detail.id)
//   if (conversation) {
//     conversation.classList.remove("bg-gradient-to-r", "border-x-red-500")
//     conversation.classList.add("hover:bg-gradient-to-r", "hover:border-x-red-100")

//     let name = conversation.querySelector("h1")
//     name.classList.remove("text-gray-800")
//     name.classList.add("text-gray-700")

//     let subject = conversation.querySelector("p")
//     subject.classList.remove("text-gray-700")
//     subject.classList.add("text-gray-600")
//   }
// })
