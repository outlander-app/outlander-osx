import React from 'react'
import { console } from './core'
import Math2 from './Math2'
import TestRenderer from 'react-test-renderer';

const App = (props) => (
  <a href={props.page}>{props.children}</a>
)

const testRenderer = TestRenderer.create(
  <App page="https://www.facebook.com/">Facebook</App>
)

const json = testRenderer.toJSON();

console.log(json)
