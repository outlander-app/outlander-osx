var webpack = require('webpack')
var path = require('path')

module.exports = [
  {
    mode: 'development',

    entry: {
      'bundle': './src/app/index.js',
    },

    output: {
      path: path.resolve('./.build'),
      filename: '[name].js'
    },

    resolve: {
      extensions: ['.js', '.json']
    },

    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader"
          }
        }
      ]
    },

    plugins: [
    ]
  }
]
