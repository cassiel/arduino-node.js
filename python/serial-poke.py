# Test code in Python.

import serial

ser = serial.Serial(port="/dev/ttyACM0", baudrate=9600)


for i in range(20):
    print "[%d]" % i
    ser.write(bytearray([ord('+') | 0x80,
                         0, 1 & 0xF,
                         0, 10 & 0xF,
                         0x80]))
    ser.flush()

    # We expect back a two-byte payload, so 6 bytes total:
    # command, byte 1 (MSB, LSB), byte 2 (MSB, LSB), terminator.
    bb = ser.read(6)

    print(''.join((' %02x' % ord(i)) for i in bb))

    #for j in range(len(bb)):
        #print "    [%d] -> %d" % (j, ord(bb[j]))

ser.close()
