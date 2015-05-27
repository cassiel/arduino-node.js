# -*- coffee-tab-width: 4; -*-

comms = require "./comms"

doit = (p) ->
    callbacks =
        '+': (data) -> console.log "<<< +: #{(data[0] << 8) + data[1]}"

    console.log "opening #{p}..."

    c = new comms.Comms p,
        baudrate: 9600
        callbacks

    #setInterval (() -> c.rawWrite a), 1000

    light = 1
    times = 0

    timer = null

    f = ->
        if times == 20
            clearInterval timer
            c.close()
        else
            console.log "[#{times}]"
            c.xmit 'L', [light]
            light = 1 - light

            n1 = Math.floor(Math.random() * 256)
            n2 = Math.floor(Math.random() * 256)
            console.log ">>> #{n1} + #{n2}"
            c.xmit '+', [n1, n2]

            times = times + 1

    timer = setInterval f, 250

comms.listPorts (ps) ->
    if ps.length == 0
        console.log "no Arduino found"
    else
        doit ps[0]
