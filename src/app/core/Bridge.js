var that = this

var modules = {
  math: {
    add: function (x, y) {
      nativeCallback('math', 'add', [x,y])
      return x + y;
    }
  },
  win: {
    get: function() {
      return that
    }
  }
};

var Bridge = {
  callFunction: function(moduleName, method, args) {
    var module = modules[moduleName]
    return module[method].apply(null, args)
  }
}

function require(module) {
  return modules[module]
}
