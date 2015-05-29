`-*- mode: markdown; mode: visual-line; mode: adaptive-wrap-prefix; -*-`

# `arduino-polyglot`

Generic Arduino protocol and comms for Python, Ruby, and Javascript/CoffeeScript under Node.js.

## Status

- Node.js is done
- Python is done
- Ruby still to be ported from other projects

## Introduction

This is a front-end package for talking to an Arduino with Python, Ruby and Node.js. It's a child project of [arduino-clj](https://github.com/cassiel/arduino-clj), which contains the back-end Arduino code and a front-end for Clojure; this project just adds front-ends for Python, Ruby and Node.js, talking to the same back-end. Refer to `arduino-clj` for protocol reference, Arduino installation instructions and so on.

For initial testing, follow the Python route and get `serial-poke.py` working (unless you're happier hacking at Node.js).

### Python

The code works under Python 2 and Python 3.

- On OS X, the serial package for Python 2.x isn't installed by default, so:

        sudo pip install pyserial
        
  Or you can do what all the cool kids do, and run Python inside a [virtual environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/), so that packages can be installed without `sudo` (and so that any configuration mistakes can be discarded).

- There's a simple test script in `python/serial-poke.py`. This script doesn't parse our serial protocol, but does blindly transmit valid messages which the Arduino will respond to, and has a generic printing routine with a timeout for debugging. After a few exchanges, it should hex-print complete responses, each of which starts with a high-bit-set byte and ends with `0x80`.

  Don't forget to set the serial port name (`/dev/ttyXXXXX`) correctly.
  
The library is in `comms.py`. It provides a single class, called `Comms`. The constructor takes an obligatory argument for the port name, followed by optional keyword arguments for the serial options.

Create a subtype of `Comms` and provide a method `handle(command, data)` to actually deal with incoming messages.

For example:

```python
class LedFlash(Comms):
    def __init__(self):
        Comms.__init__(self, "/dev/cu.usbmodem14171", baudrate=9600, timeout=0.25)

    def handle(self, command, data):
        if command == "+":
            print("<<< +: %d" % ((data[0] << 8) + data[1]))

c = LedFlash()
```

Transmit to the Arduino using `xmit`:

```python
c.xmit('L', [light])
...
c.xmit('+', [n1, n2])
```

Unlike the Node.js version, the serial port has to be polled repeatedly. Call `service` with an argument specifying the maximum number of bytes to service; it will return the number of bytes actually read. (Note that these numbers are actual serial bytes, not bytes of command payload.) This call will block unless the serial timeout is set to `0` (to return immediately) or some positive float value to timeout when data is not available; use which ever best fits the rest of the application. For example:

```python
def drain():
    while True:
        n = c.service(1)
        if n == 0: break
```

Close the port (if desired) with `close`.

See `led-flash.py` for a complete example.

### Node.js

- Install [Node.js](https://nodejs.org/).
- Install [node serialport](https://github.com/voodootikigod/node-serialport) (via `npm`). Under OS X and Linux this can't be installed globally with `-g` (because, well, Javascript); a local `npm install serialport` seems to work fine.
- Our CoffeeScript sources are in directory `coffee`; to automatically compile these into Javascript, install CoffeeScript (`sudo npm install -g coffee-script`) - which might require the `node` command in order to run (via `sudo apt-get install nodejs-legacy`) and then:

        coffee -c -w -o __js/ coffee/
        
  This will auto-watch and compile changed files. (It'll need to be relaunched if any new files are added.) Note that `coffee/*.coffee` works better as a source if you're an Emacs user (otherwise the auto-watch gets confused by Emacs auto-save files).
- The file `serial-poke.coffee` roughly mimics its Python equivalent: it sends a valid command to the Arduino every quarter second, and also prints out valid responses. Rather than timing out read requests, it just examines incoming data asyncronously looking for each terminating `0x80` (so it does have a minimal understanding of the protocol).

The library is in `comms.coffee`. It exports two functions: `listPorts` (which lists all ports which appear to be connected to Arduinos), and `open` (to open a port for reading and writing). Both functions are callback-based, since the underlying serial library works that way. With the right call chaining, a script can open the first Arduino it finds, for example:

```coffee
comms = require "./comms"

comms.listPorts (ps) ->
    if ps.length == 0
        console.log "no Arduino found"
    else
        doit ps[0]
```

The `doit` function called here takes a port name (a string). It will probably call `comms.open`:

```coffee
doit = (p) ->
    comms.open p,
        {baudrate: 9600}
        '+': (data) -> console.log "<<< +: #{(data[0] << 8) + data[1]}"
        'Q': (data) -> doSomethingWith data
        action
```

The `open` function takes four arguments. (While reading the example above, recall that CoffeeScript collapses consecutive key/value pairs into a single record - this is why the serial options record is written in braces.)

- The port name
- A record of options for the Node.js serial driver (q.v.)
- A record of command callbacks. See `arduino-clj` for the details, but this record has keys which are single-character strings - the command names back from the Arduino - and each key maps to a function taking a list of bytes as argument.
- A callback to be called when the port opens. This callback is passed a transmitter object for sending data (and for closing the port):

```coffee
action = (c) ->
    ...
    c.xmit 'L', [0]
    c.xmit '+', [1, 2, 99]
    ...
    c.close()
```

The transmitter method `xmit` takes a single-character string (the command) and a list of bytes (the data). The method `close` closes the port.

The example file `led-flash.coffee` is a complete example using the default Arduino code template from the [arduino-clj](https://github.com/cassiel/arduino-clj) project. It flashes the internal LED (#13) and exercises a simple calculator.
