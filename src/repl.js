#!/usr/bin/env node

const repl = require('repl');
const fs = require('fs')


// Link to Elm code
var Elm = require('./main').Elm;
var main = Elm.Main.init();

// Eval function for the repl
function eval(input, _, __, callback) {
  // console.log ("JS, INPUT: " + input)
  main.ports.put.subscribe(
    function putCallback (data) {
      main.ports.put.unsubscribe(putCallback)
      // console.log("JS, DATA:", data)
      callback(null, data)
    }
  )
  main.ports.get.send(input)
}


function myWriter(output) {
  return output
}

let leadingSpace = "    "
let helpDivider = leadingSpace + "---------------------------------------------\n"
let helpTitle = leadingSpace + "MicroScheme Interpreter V0.1.2\n\n"
let helpExample = leadingSpace + "Example: > (+ 1 2 3)\n\n"
let helpMoreInfo = leadingSpace + "Type 'help' for more information\n"
let helpReference1 = leadingSpace + "Reference manual:\n"
let helpReference2 = leadingSpace + "https://jxxcarlson.github.io/elm-microscheme/\n"
let helpString = "\n" + helpDivider + helpTitle + helpExample + helpMoreInfo + "\n" + helpReference1 + helpReference2 + helpDivider

console.log(helpString)

repl.start({ prompt: '> ', eval: eval, writer: myWriter});

