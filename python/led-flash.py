from comms import Comms
import random

class LedFlash(Comms):
    def __init__(self):
        Comms.__init__(self, "/dev/cu.usbmodem14171", baudrate=9600, timeout=0.25)

    def handle(self, command, data):
        if command == "+":
            print("<<< +: %d" % ((data[0] << 8) + data[1]))

c = LedFlash()

def drain():
    while True:
        n = c.service(1)
        if n == 0: break

light = 1

for i in range(20):
    print("[%d]" % i)
    c.xmit('L', [light])
    light = 1 - light
    n1 = random.randint(0, 255)
    n2 = random.randint(0, 255)
    print(">>> %d + %d" % (n1, n2))
    c.xmit('+', [n1, n2])
    drain()

c.close()
