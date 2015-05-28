from comms import Comms
import random
def printer(data):
    print "<<< +: %d" % ((data[0] << 8) + data[1])

c = Comms("/dev/cu.usbmodem14171",
          {'baudrate': 9600, 'timeout': 0.25},
          {'+': printer})

def drain():
    while True:
        n = c.service(1)
        if n == 0: break

light = 1

for i in range(20):
    print "[%d]" % i
    c.xmit('L', [light])
    light = 1 - light
    n1 = random.randint(0, 255)
    n2 = random.randint(0, 255)
    print ">>> %d + %d" % (n1, n2)
    c.xmit('+', [n1, n2])
    drain()
