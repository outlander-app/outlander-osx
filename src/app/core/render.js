import createElement from './createElement'
import console from './console'

async function render(element, callback) {
  const container = createElement('ROOT')

  await new Promise((resolve, reject) => {
    console.log('rendered')
    resolve()
	})
}

export default render
