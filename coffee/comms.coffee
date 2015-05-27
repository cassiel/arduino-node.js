# -*- coffee-tab-width: 4; -*-

sp = require("serialport")
SerialPort = sp.SerialPort

ARDUINO_MANUFACTURER = /^Arduino.*$/

# More Javascript callback hell:
listPorts = (cb) ->
    result = []
    sp.list (err, ports) ->
        if err
            console.log err
        else
            ports.forEach (p) ->
                #console.log "examining #{JSON.stringify p}"
                if ARDUINO_MANUFACTURER.test p.manufacturer
                    result.push p.comName

            cb result

# The Comms takes a port, a map of options for SerialPort, and a second
# map of callbacks (each of which is a character to a function from byte
# array). CoffeeScript Danger Will Robinson: be careful to pass the two
# maps separately (so write one of them in {...} form, or bind to a
# variable first). Final design tweak, drinking the Javascript juice:
# our top-level "open" function takes a callback (natch) which is called
# with a writer class (containing xmit and close).

class Connection
    constructor: (@serialPort, @callbacks) ->
        this.__inMessage = []

        this.serialPort.on "data", (data) =>
            for b in data
                this.handleByte b

    handleByte: (b) ->
        im = this.__inMessage
        im.push b
        if b == 0x80
            #console.log im.map((i) -> ("0" + i.toString 16).slice -2).join " "
            if im.length > 0 and im[0] > 0x80     # Quick sanity check at startup
                cmd = String.fromCharCode im[0] & 0x7F
                cb = this.callbacks[cmd]
                # Do we have a callback for this command character?
                if cb
                    data = []
                    len = (im.length - 2) / 2
                    for i in [0..len-1]
                        data.push (im[1 + i * 2] << 4) | im[2 + i * 2]
                    cb data

            this.__inMessage = []

    rawWrite: (a) ->
        if this.serialPort.isOpen()
            buf = new Buffer a
            this.serialPort.write buf, (err, results) ->
                if err
                    console.log "err: #{err}"
            this.serialPort.drain()
        else
            console.log "port not open"

    xmit: (ch, bytes) ->
        a = [(ch.charCodeAt 0) | 0x80]
        for b in bytes
            a.push(b >> 4)
            a.push(b & 0x0F)
        a.push 0x80
        #console.log a
        this.rawWrite a

    close: ->
        this.serialPort.close() if this.serialPort.isOpen()

open = (port, options, callbacks, writerFn) ->
    serialPort = new SerialPort port, options
    serialPort.on "open", ->
        writerFn (new Connection serialPort, callbacks)

module.exports =
    listPorts: listPorts
    open: open
