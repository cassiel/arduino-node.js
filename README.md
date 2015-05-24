`-*- mode: markdown; mode: visual-line; mode: adaptive-wrap-prefix; -*-`

# `arduino-node.js`

Generic Arduino protocol and comms for Javascript/CoffeeScript under Node.js.

This is a front-end package for talking to an Arduino with Node.js. It's a child project of [arduino-clj](https://github.com/cassiel/arduino-clj), which contains the back-end Arduino code and a front-end for Clojure; this project just adds a Javascript/CoffeeScript front-end, talking to the same back-end. Refer to `arduino-clj` for protocol reference, Arduino installation instructions and so on.

## Installation

- Install [Node.js](https://nodejs.org/)
- Install [node serialport](https://github.com/voodootikigod/node-serialport) (via `npm`). On the Mac I do a `sudo npm install -g serialport` (which currently isn't working); same on Ubuntu.

## Running

- Our CoffeeScript sources are in directory `coffee`; to automatically compile these into Javascript, install CoffeeScript (`sudo npm -install -g coffee` - which might require the `node` command, via `sudo apt-get install nodejs-legacy`) and then:

        coffee -c -w -o __js/ coffee/
        
  This will auto-watch and compile changed files. (It'll need to be relaunched if any new files are added.)
  
  
