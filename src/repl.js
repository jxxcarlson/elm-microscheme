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

console.log("\n  --------------------------------\n    MicroScheme Interpreter V0.1.2\n\n    Example: > (+ 1 2 3)\n\n    Type 'help' for more information\n    --------------------------------\n")

repl.start({ prompt: '> ', eval: eval, writer: myWriter});
