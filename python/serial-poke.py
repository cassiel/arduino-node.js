# Test code in Python.

import serial

ser = serial.Serial(port="/dev/ttyACM0", baudrate=9600, timeout=0.1)

for i in range(20):
    print "[%d]" % i
    ser.write(bytearray([ord('+') | 0x80,
                         0, 1 & 0xF,
                         0, 10 & 0xF,
                         0x80]))
    ser.flush()

    # This is a simple, protocol-agnostic read: fetch characters until we time out.
    # After a while it should settle down to 0xAB ... 0x80 sequences.
    buf = []
    going = True

    while going:
        bb = ser.read()
        if len(bb) == 0:
            going = False
        else:
            for i in bb: buf.append(ord(i))

    print(''.join((' %02x' % i) for i in buf))

ser.close()
