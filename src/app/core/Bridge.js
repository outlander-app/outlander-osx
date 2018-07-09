import console from './console'

const modules = {
  math: {
    add: function (x, y) {
      nativeCallback('math', 'add', [x,y])
      return x + y;
    }
  }
};

const Bridge = {
  callFunction: function(moduleName, method, args) {
    var module = modules[moduleName]
    return module[method].apply(null, args)
  },

  registerModule: function(name, module) {
    console.log('registerModule', name)
    modules[name] = module
  }
}

global.Bridge = Bridge

export default Bridge
