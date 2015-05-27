`-*- mode: markdown; mode: visual-line; mode: adaptive-wrap-prefix; -*-`

# `arduino-polyglot`

Generic Arduino protocol and comms for Python, Ruby, and Javascript/CoffeeScript under Node.js.

This is a front-end package for talking to an Arduino with Python, Ruby and Node.js. It's a child project of [arduino-clj](https://github.com/cassiel/arduino-clj), which contains the back-end Arduino code and a front-end for Clojure; this project just adds front-ends for Python, Ruby and Node.js, talking to the same back-end. Refer to `arduino-clj` for protocol reference, Arduino installation instructions and so on.

## Installation

For initial testing, follow the Python route and get `serial-poke.py` working.

### Python

- On OS X, the serial package for Python 2.x isn't installed by default, so:

        sudo pip install pyserial
        
  Or you can do what all the cool kids do, and run Python inside a [virtual environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/), so that packages can be installed without `sudo` (and so that any configuration mistakes can be discarded).

- There's a simple test script in `python/serial-poke.py`. This script doesn't parse our serial protocol, but does blindly transmit valid messages which the Arduino will respond to, and has a generic printing routine with a timeout for debugging. After a few exchanges, it should hex-print complete responses, each of which starts with a high-bit-set byte and ends with `0x80`.

  Don't forget to set the serial port name (`/dev/ttyXXXXX`) correctly.

### Node.js

- Install [Node.js](https://nodejs.org/)
- Install [node serialport](https://github.com/voodootikigod/node-serialport) (via `npm`). Under OS X and Linux this can't be installed globally with `-g` (because, well, Javascript); a local `npm install serialport` seems to work fine.
- Our CoffeeScript sources are in directory `coffee`; to automatically compile these into Javascript, install CoffeeScript (`sudo npm install -g coffee-script`) - which might require the `node` command in order to run (via `sudo apt-get install nodejs-legacy`) and then:

        coffee -c -w -o __js/ coffee/
        
  This will auto-watch and compile changed files. (It'll need to be relaunched if any new files are added.) Note that `coffee/*.coffee` works better as a source if you're an Emacs user (otherwise the auto-watch gets confused by Emacs auto-save files).
- The file `serial-poke.coffee` roughly mimics its Python equivalent: it sends a valid command to the Arduino every second, and also prints out valid responses. Rather than timing out read requests, it just examines incoming data asyncronously looking for each terminating `0x80` (so it does have a minimal understanding of the protocol).
