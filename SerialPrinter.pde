import processing.serial.*;

negligencia_artificial pde = this; // Nice Hack!

class SerialPrinter {
  
  Serial serial;  // Create object from Serial class
  String inputText;
  boolean noSerial = true;
  
  SerialPrinter(int port) {
    if(Serial.list().length <= 0) return;
    String portName = Serial.list()[0];
    serial = new Serial(pde, portName, port);
    noSerial = false;
  }
  SerialPrinter(int port, String portName) {
     serial = new Serial(pde, portName, port);
     noSerial = false;
  }
  
  void exe() {
    print();
    draw();
    if(!noSerial) serial.clear();
  }
  
  void print() {
    if(noSerial) return;
    if(serial.available() > 0) {
      inputText = serial.readString(); 
      println(inputText);
    }
  }
  
  void draw() {
    push();
    translate(0, height - 16);
    fill(255);
    noStroke();
    rect(0, 0, width, 16);
    textSize(12);
    fill(0);
    if(noSerial){
      text("no serial >.<", 4, 14);
      
      pop();
      return;
    }
    
    text(inputText, 4, 14);
    pop();
  }

}
