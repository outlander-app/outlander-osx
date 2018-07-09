
const console = {
  log() {
    log2(arguments)
    global.console && global.console.log.apply(null, arguments)
  },

  error() {
    log2(arguments)
    global.console && global.console.error.apply(null, arguments)
  }
}

export default console
