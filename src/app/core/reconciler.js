import emptyObject from 'fbjs/lib/emptyObject'
import ReactReconciler from 'react-reconciler'
import { createElement, getHostContextNode } from './createElement'

const rootHostContext = {}
const childHostContext = {}

const NativeReconciler = ReactReconciler({
  appendInitialChild(parentInstance, child) {
    if (parentInstance.appendChild) {
      parentInstance.appendChild(child)
    }
  },

  createInstance(type, props, internalInstanceHandle) {
    return createElement(type, props, internalInstanceHandle)
  },

  createTextInstance(text, rootContainerInstance, internalInstanceHandle) {
    return text
  },

  finalizeInitialChildren(wordElement, type, props) {
    return false
  },

  getPublicInstance(inst) {
    return inst
  },

  prepareForCommit() {
    // noop
  },

  prepareUpdate(wordElement, type, oldProps, newProps) {
    return true
  },

  resetAfterCommit() {
    // noop
  },

  resetTextContent(wordElement) {
    // noop
  },

  getRootHostContext(instance) {
    return getHostContextNode(instance)
  },

  getChildHostContext(instance) {
    return emptyObject
  },

  shouldSetTextContent(type, props) {
    return false
  },

  now: () => Date.now,

  useSyncScheduling: true,

  supportsMutation: false,
})

export default NativeReconciler
