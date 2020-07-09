const webpack = require("webpack");
const autoprefixer = require("autoprefixer");
const path = require("path");
const MODE =
  process.env.npm_lifecycle_event === "build" ? "production" : "development";


module.exports = function(env) {
  return {
    mode: MODE,
    entry: {
      main: "./index.js",
    },
    context: path.resolve(__dirname),
    output: {
      path: path.resolve(__dirname, "dist"),
      // filename: "bundle.js"
    },
    plugins:
      MODE === "development"
        ? [
            // Suggested for hot-loading
            new webpack.NamedModulesPlugin(),
            // Prevents compilation errors causing the hot loader to lose state
            new webpack.NoEmitOnErrorsPlugin()
          ]
        : [],
    module: {
      rules: [
        {
          test: /\.(svg|woff|eot|woff2|ttf)$/i,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[hash].[ext]',
              }
            },
          ],
        },
        {
          test: /\.html$/,
          exclude: /node_modules/,
          loader: "file-loader?name=[name].[ext]"
        },
        {
          test: /\.s?css$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].css',
              }
            },
            { loader: 'extract-loader' },
            { loader: 'css-loader' },
            { 
              loader: 'postcss-loader',
              options: {
                plugins: () => [autoprefixer()]
              }
            },
            {
              loader: 'sass-loader',
              options: {
                // Prefer Dart Sass
                implementation: require('sass'),

                // See https://github.com/webpack-contrib/sass-loader/issues/804
                webpackImporter: false,
                sassOptions: {
                  includePaths: [ './node_modules' ]
                }
              }
            }
          ]
        },
        {
          test: [/\.elm$/],
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            { loader: "elm-hot-webpack-loader" },
            {
              loader: "elm-webpack-loader",
              options:
                MODE === "production" ? {} : { debug: true, forceWatch: true }
            }
          ]
        },
        { test: /\.ts$/, loader: "ts-loader" }
      ]
    },
    resolve: {
      extensions: [".js", ".ts", ".elm", ".scss", ".css"]
    },
    serve: {
      inline: true,
      stats: "errors-only"
    }
  };
};
