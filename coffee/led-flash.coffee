comms = require "./comms"

callbacks =
        '+': (data) -> console.log '+'

c = new comms.Comms "/dev/tty.usbmodem1451",
        baudrate: 9600
        callbacks

#setInterval (() -> c.rawWrite a), 1000

light = 1

f = () ->
        c.xmit 'L', [light]
        c.xmit '+', [2, 3]
        light = 1 - light

setInterval f, 1000
