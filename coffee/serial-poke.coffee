SerialPort = require("serialport").SerialPort

serialPort = new SerialPort "/dev/tty.usbmodem1451",
        baudrate: 9600

serialPort.on "open", ->
        console.log "open"

        inMessage = []

        handleByte = (b) ->
                inMessage.push b
                if b == 0x80
                        console.log inMessage.map((i) -> ("0" + i.toString 16).slice -2).join " "
                        inMessage = []

        serialPort.on "data", (data) ->
                for b in data
                        handleByte b

        a = [('+'.charCodeAt 0) | 0x80, 0, 1 & 0xF, 0, 10 & 0xF, 0x80]
        buf = new Buffer a

        ww = ->
                serialPort.write buf, (err, results) ->
                        console.log "err: #{err}"
                        console.log "results: #{results}"
                serialPort.drain()

        setInterval ww, 1000
