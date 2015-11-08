class LedFlash extends Comms {
    LedFlash(PApplet sketch) {
        super(sketch, "/dev/cu.usbmodem1411", 9600);
    }
    
    void handle(char command, byte[] data) {
        if (command == '+' && data.length == 2) {
            System.out.println("Got: [" + data[0] + ", " + data[1] + "]");
        }
    }
}

Comms c = new LedFlash(this);

void setup() {
    int light = 1;
    byte[] bytes = new byte[1];
    
    for (int i = 0; i < 20; i++) {
        System.out.println(String.format("[%d]", i));
        bytes[0] = (byte) light;
        c.xmit('L', bytes);
        light = 1 - light;
        try { Thread.sleep(100); } catch (Exception _) { }
    }
    
    c.xmit('+', new byte[] { 1, 2, 3 });
}

void draw() {
    c.service();
}