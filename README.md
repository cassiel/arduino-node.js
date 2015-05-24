`-*- mode: markdown; mode: visual-line; mode: adaptive-wrap-prefix; -*-`

# `arduino-polyglot`

Generic Arduino protocol and comms for Python, Ruby, and Javascript/CoffeeScript under Node.js.

This is a front-end package for talking to an Arduino with Python, Ruby and Node.js. It's a child project of [arduino-clj](https://github.com/cassiel/arduino-clj), which contains the back-end Arduino code and a front-end for Clojure; this project just adds front-ends for Python, Ruby and Node.js, talking to the same back-end. Refer to `arduino-clj` for protocol reference, Arduino installation instructions and so on.

## Installation

For initial testing, follow the Python route and get `serial-poke.py` working.

### Python

- There's a simple test script in `python/serial-poke.py`. This script doesn't parse our serial protocol, but does blindly transmit valid messages which the Arduino will respond to, and has a generic printing routine with a timeout for debugging. After a few exchanges, it should hex-print complete responses, each of which starts with a high-bit-set byte and ends with `0x80`.

### Node.js

- Install [Node.js](https://nodejs.org/)
- Install [node serialport](https://github.com/voodootikigod/node-serialport) (via `npm`). On the Mac I do a `sudo npm install -g serialport` (which currently isn't working); same on Ubuntu (which also isn't working, because, well, Javascript; a local `npm install serialport` seems more functional).
- Our CoffeeScript sources are in directory `coffee`; to automatically compile these into Javascript, install CoffeeScript (`sudo npm -install -g coffee` - which might require the `node` command, via `sudo apt-get install nodejs-legacy`) and then:

        coffee -c -w -o __js/ coffee/
        
  This will auto-watch and compile changed files. (It'll need to be relaunched if any new files are added.)
- The file `serial-poke.coffee` roughly mimics its Python equivalent: it sends a valid command to the Arduino every second, and also prints out valid responses. Rather than timing out read requests, it just examines incoming data asyncronously looking for each terminating `0x80` (so it does have a minimal understanding of the protocol).
