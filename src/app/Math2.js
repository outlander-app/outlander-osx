import { console, Bridge } from './core'

const Math2 = {
  multiply(x, y) {
    console.log('multiply', x, y)
    return x*y
  }
}

Bridge.registerModule('Math2', Math2)
