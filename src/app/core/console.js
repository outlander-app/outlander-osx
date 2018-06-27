
const console = {
  log(arg) {
    log2(arguments)
  },

  error() {
    log2(arguments)
  }
}

global.console = console

export default console
