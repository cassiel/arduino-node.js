# -*- coffee-tab-width: 4; -*-

SerialPort = require("serialport").SerialPort

serialPort = new SerialPort "/dev/tty.usbmodem14171",
    baudrate: 9600

serialPort.on "open", ->
    console.log "open"

    # Incoming message buffer:
    inMessage = []

    handleByte = (b) ->
        inMessage.push b
        if b == 0x80
            console.log inMessage.map((i) -> ("0" + i.toString 16).slice -2).join " "
            inMessage = []

    serialPort.on "data", (data) ->
        for b in data
            handleByte b

    # Well-formed message:
    a = [('+'.charCodeAt 0) | 0x80, 0, 1 & 0xF, 0, 10 & 0xF, 0x80]
    buf = new Buffer a

    timer = null
    tries = 0

    ww = ->
        if tries < 20
            console.log "[#{tries}]"
            serialPort.write buf, (err, results) ->
                if err then console.log "err: #{err}"
                console.log "len: #{results}"
            serialPort.drain()
            tries = tries + 1
        else
            clearInterval timer
            serialPort.close()

    timer = setInterval ww, 250
