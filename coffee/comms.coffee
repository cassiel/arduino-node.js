SerialPort = require("serialport").SerialPort

# The Comms takes a port, a map of options for SerialPort, and a second map of callbacks (each of
# which is a character to a function from byte array). CoffeeScript Danger Will Robinson: be careful
# to pass the two maps separately (so write the second one in {...} form, or bind to a variable first)

class Comms
        constructor: (@port, @options, @callbacks) ->
                this.__opened = false
                this.__serialPort = new SerialPort @port, @options

                opener = ->
                        console.log "open"
                        this.__opened = true

                this.__serialPort.on "open", opener.bind this

                inMessage = []

                handleByte = (b) ->
                        inMessage.push b
                        if b == 0x80
                                console.log inMessage.map((i) -> ("0" + i.toString 16).slice -2).join " "
                                if inMessage.length > 0 and inMessage[0] > 0x80         # Quick sanity check at startup
                                        cmd = inMessage[0] & 0x7F
                                        data = []
                                        len = (inMessage.length - 2) / 2
                                        for i in [0..len-1]
                                                data.push (inMessage[1 + i * 2] << 4) | inMessage[2 + i * 2]
                                        console.log "data", data
                                inMessage = []

                this.__serialPort.on "data", (data) ->
                        for b in data
                                handleByte b

        rawWrite: (a) ->
                if this.__opened
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
                console.log a
                this.rawWrite a

module.exports =
        Comms: Comms
