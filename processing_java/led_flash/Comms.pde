import processing.serial.*;

abstract class Comms {
    private Serial itsPort;
    private char itsCommand;
    private byte itsCurrentByte;
    private boolean itsFirstNybble;
    private ArrayList<Byte> itsData;
    
    public Comms(PApplet sketch, String port, int baudRate) {
        itsPort = new Serial(sketch, port, baudRate);
    }
    
    public void xmit(char cmd, byte[] data) {
        byte[] buffer = new byte[data.length * 2 + 2];
        
        buffer[0] = (byte) (cmd + 0x80);
        
        for (int i = 0; i < data.length; i++) {
            buffer[1 + i * 2] = (byte) (data[i] >> 4);
            buffer[2 + i * 2] = (byte) (data[i] & 0x0F);
        }
        
        buffer[data.length * 2 + 1] = (byte) 0x80;
        
        itsPort.write(buffer);
    }
    
    private void handleByte(byte b) {
        if (b == 0x80) {
            Byte[] tmp = itsData.toArray(new Byte[] { });
            byte[] d = new byte[tmp.length];
            
            for (int i = 0; i < tmp.length; i++) {
                d[i] = tmp[i];
            }
            
            handle(itsCommand, d);
        } else if ((b & 0x80) != 0) {
            itsCommand = (char) (b & 0x7F);
            itsFirstNybble = true;
            itsData = new ArrayList<Byte>();
        } else {
            if (itsFirstNybble) {
                itsCurrentByte = b;
            } else {
                itsData.add((byte) ((itsCurrentByte << 4) | b));
            }
            
            itsFirstNybble = !itsFirstNybble;
        }
    }
    
    abstract public void handle(char command, byte[] data);
    
    public void service() {
        while (itsPort.available() > 0) {
            handleByte((byte) itsPort.read());
        }
    }
    
    public void close() {
        itsPort.stop();
    }
}