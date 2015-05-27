# -*- coffee-tab-width: 4; -*-

SerialPort = require("serialport").SerialPort

# The Comms takes a port, a map of options for SerialPort, and a second
# map of callbacks (each of which is a character to a function from byte
# array). CoffeeScript Danger Will Robinson: be careful to pass the two
# maps separately (so write one of them in {...} form, or bind to a
# variable first)

class Comms
    constructor: (@port, @options, @callbacks) ->
        this.__portName = @port
        this.__serialPort = new SerialPort @port, @options
        this.__callbacks = @callbacks
        this.__inMessage = []

        opener = -> console.log "opened #{this.__portName}"

        this.__serialPort.on "open", opener.bind this

        this.__serialPort.on "data", (data) =>
            for b in data
                this.handleByte b

    handleByte: (b) ->
        im = this.__inMessage
        im.push b
        if b == 0x80
            #console.log im.map((i) -> ("0" + i.toString 16).slice -2).join " "
            if im.length > 0 and im[0] > 0x80     # Quick sanity check at startup
                cmd = String.fromCharCode im[0] & 0x7F
                cb = this.__callbacks[cmd]
                if cb
                    data = []
                    len = (im.length - 2) / 2
                    for i in [0..len-1]
                        data.push (im[1 + i * 2] << 4) | im[2 + i * 2]
                    cb data

            this.__inMessage = []

    rawWrite: (a) ->
        if this.__serialPort.isOpen()
            buf = new Buffer a
            this.__serialPort.write buf, (err, results) ->
                if err
                    console.log "err: #{err}"
            this.__serialPort.drain()
        else
            console.log "port not open yet"

    xmit: (ch, bytes) ->
        a = [(ch.charCodeAt 0) | 0x80]
        for b in bytes
            a.push(b >> 4)
            a.push(b & 0x0F)
        a.push 0x80
        #console.log a
        this.rawWrite a

module.exports =
    Comms: Comms
