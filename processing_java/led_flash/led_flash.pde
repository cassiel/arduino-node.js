class LedFlash extends Comms {
    LedFlash(PApplet sketch) {
        super(sketch, "/dev/cu.usbmodem1421", 9600);
    }

    void handle(char command, byte[] data) {
        if (command == '+' && data.length == 2) {
            System.out.println("Got: [" + data[0] + ", " + data[1] + "]");
        }
    }
}

Comms c = new LedFlash(this);
int lastSample = millis();

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
}

byte rand_byte(int lim) {
    return (byte) random(lim);
}

void draw() {
    if (lastSample + 250 < millis()) {
        byte[] b = new byte[] {
            rand_byte(8),
            rand_byte(120),
            rand_byte(120),
            rand_byte(120)
        };
        c.xmit('+', b);
        c.xmit('C', b);
        lastSample = millis();
    }

    c.service();
}