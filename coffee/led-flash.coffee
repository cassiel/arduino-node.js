# -*- coffee-tab-width: 4; -*-

comms = require "./comms"

callbacks =
    '+': (data) -> console.log "<<< +: #{(data[0] << 8) + data[1]}"

c = new comms.Comms "/dev/tty.usbmodem14171",
    baudrate: 9600
    callbacks

#setInterval (() -> c.rawWrite a), 1000

light = 1

f = ->
    c.xmit 'L', [light]
    light = 1 - light

    n1 = Math.floor(Math.random() * 256)
    n2 = Math.floor(Math.random() * 256)
    console.log ">>> #{n1} + #{n2}"
    c.xmit '+', [n1, n2]

setInterval f, 1000
