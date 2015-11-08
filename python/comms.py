'''
Serial protocol handler in Python. (See also: CoffeeScript, Ruby, Clojure.)
'''
import serial

class Comms:
    def __init__(self, port, **options):
        '''
        Initialise with a port name plus serial options.
        '''
        self.__serial = serial.Serial(port=port, **options)
        self.__command = 0
        self.__firstNybble = True
        self.__currentByte = 0
        self.__data = []

    def handleByte(self, byte):
        '''
        Slightly different coding than the CoffeeScript version, for hysterical reasons.
        Here we pack the bytes as we go.
        '''
        if byte == 0x80:                                # End of message
            self.handle(chr(self.__command), self.__data)
        elif byte & 0x80:                               # Start of message
            self.__command = byte & 0x7F
            self.__firstNybble = True
            self.__data = []
        else:
            if self.__firstNybble:
                self.__currentByte = byte
            else:
                self.__data.append((self.__currentByte << 4) | byte)

            self.__firstNybble = not self.__firstNybble

    def handle(self, command, data):
        '''
        Subclass Comms and provide a handler to deal with incoming data.
        '''
        pass

    def service(self, n):
        '''
        Attempt to service up to `n` bytes. May block if timeout is None.
        Return number of bytes processed.
        '''
        bb = self.__serial.read()
        for i in bb:
            if isinstance(i, str): i = ord(i)
            self.handleByte(i)
        return len(bb)

    def xmit(self, cmd, data):
        b = [ord(cmd) | 0x80]
        for d in data:
            b.append(d >> 4)
            b.append(d & 0x0F)

        b.append(0x80)
        self.__serial.write(bytearray(b))
        self.__serial.flush()

    def close(self):
        self.__serial.close()
