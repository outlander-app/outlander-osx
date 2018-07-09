class RootView {
}

class TextView {
}

let ROOT_NODE_INSTANCE = null;

function getHostContextNode(rootNode) {
  if (typeof rootNode !== undefined) {
    return (ROOT_NODE_INSTANCE = rootNode)
  } else {
    console.warn(`${rootNode} is not an instance of officegen docx constructor.`)

    return (ROOT_NODE_INSTANCE = new RootView())
  }
}

function createElement(type, props, internalInstance) {
  const COMPONENTS = {
    ROOT: () => new RootView(),
    TEXT: () => new TextView(ROOT_NODE_INSTANCE, props),
    default: undefined,
  };

  return COMPONENTS[type]() || COMPONENTS.default;
}

export { createElement, getHostContextNode };
