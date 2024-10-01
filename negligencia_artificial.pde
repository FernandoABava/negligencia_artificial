import oscP5.*;
import netP5.*;

  
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myOtraRemoteLocation;

Signal ch1; // Cara
Signal ch2; // Brazo D
Signal ch3; // Pierna
Signal ch4; // Brazo I

Signal ch1B;
Signal ch2B;
Signal ch3B;
Signal ch4B;

SerialPrinter serialPrinter; 

float maxValue = 1.0;

float smooth = 0.15;

boolean promFlag = false;
boolean promFlag2 = false;
boolean toggleSend = true;

int onOff = 1;
int dirPierna = 1;
int dirPierna2 = 1;

float outCara = 0;
float outMove = 0;
float outCabeza = 0;

boolean ismsg;

void setup() {
  fullScreen();
  frameRate(25);

  oscP5 = new OscP5(this, 3333);
  
  myRemoteLocation = new NetAddress("192.168.0.20",8888);
  myOtraRemoteLocation = new NetAddress("192.168.0.130", 3333);
  rectMode(CORNER);
  
  ch1 = new Signal(smooth);
  ch2 = new Signal(smooth);
  ch3 = new Signal(smooth);
  ch4 = new Signal(smooth);
  
  ch1B = new Signal(smooth);
  ch2B = new Signal(smooth);
  ch3B = new Signal(smooth);
  ch4B = new Signal(smooth);
  
  serialPrinter = new SerialPrinter(115200);
  
  background(255);
  smooth();
}


void draw() {
  
  // Dibuja cada onda
  ch1.draw(height * 0,      height/8);
  ch2.draw(height * 0.125,  height/8);
  ch3.draw(height * 0.25,   height/8);
  ch4.draw(height * 0.375,  height/8);
  
  ch1B.draw(height * 0.5,   height/8);
  ch2B.draw(height * 0.625, height/8);
  ch3B.draw(height * 0.75,  height/8);
  ch4B.draw(height * 0.875, height/8);
  
  ismsg = false;
  
  // Cambio de dirección. Revisa cuando se supera el promedio.
  boolean pPromFlag = promFlag;
  promFlag = ch4.value > ch4.average * 1.5;
  if( pPromFlag != promFlag && promFlag ) {
    onOff = onOff > 0 ? 0 : 1;
    dirPierna = onOff > 0 ? dirPierna * -1 : dirPierna;
  }
  
  // Segundo cambio de dirección. Revisa cuando se supera el promedio.
  boolean pPromFlag2 = promFlag2;
  promFlag2 = ch3.value > ch3.average * 1.5;
  dirPierna2 = promFlag2 ? 1 : -1;

  
  int direccion3 = ch1B.value > ch1B.average * 1.5 ? 1 : -1;
  
  if(toggleSend){
    OscMessage moveMsg = new OscMessage("/mano_mov");
    outMove = ch2.normValue; // + ch3.normValue * 0.25; // 
    outMove *= 255;
    moveMsg.add( int( outMove * dirPierna ) ); // Multiplicado por la dirección
    oscP5.send(moveMsg, myRemoteLocation);
   
    OscMessage lookMsg = new OscMessage("/mano_hi"); 
    outCara = max(ch1.normValue, ch4.normValue) * 0.75; // + ch1.normValue * 0.25; // El valor de la cara + un cuarto del valor de la pierna
    outCara *= 255;
    lookMsg.add( int( outCara * dirPierna2 ) );
    oscP5.send(lookMsg, myRemoteLocation);
    
    OscMessage cabezaMsg = new OscMessage("/cabeza"); 
    outCabeza = max(ch1B.normValue, ch2B.normValue, ch3B.normValue);// / 4; 
    outCabeza *= 255;
    cabezaMsg.add( int( outCabeza ) * direccion3 );
    oscP5.send(cabezaMsg, myRemoteLocation);
    
    pushStyle();
    fill(16, 255, 16);
    noStroke();
    ellipse(24, 24, 24, 24);
    popStyle();
  }else {
    pushStyle();
    fill(255, 16, 16);
    noStroke();
    ellipse(24, 24, 24, 24);
    popStyle();
  }
  
  serialPrinter.exe();
}

void mousePressed() {
  toggleSend = !toggleSend;
}

void oscEvent(OscMessage oscmsg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+oscmsg.addrPattern());
  println(" typetag: "+oscmsg.typetag());
  
  ismsg = true;
  
  if(oscmsg.checkAddrPattern("/wimumo002/emg")){
    float val1 = oscmsg.get(0).intValue();
    float val2 = oscmsg.get(1).intValue();
    float val3 = oscmsg.get(2).intValue();
    float val4 = oscmsg.get(3).intValue();
    
    ch1B.update(val1);
    ch2B.update(val2);
    ch3B.update(val3);
    ch4B.update(val4);
  }
  
  if(oscmsg.checkAddrPattern("/wimumo001/emg/ch1")){
    ch1.update(oscmsg.get(0).floatValue());
  } else if(oscmsg.checkAddrPattern("/wimumo001/emg/ch2")) {
    ch2.update(oscmsg.get(0).floatValue());
  } else if(oscmsg.checkAddrPattern("/wimumo001/emg/ch3")) {
    ch3.update(oscmsg.get(0).floatValue());
  } else if(oscmsg.checkAddrPattern("/wimumo001/emg/ch4")) {
    ch4.update(oscmsg.get(0).floatValue() );
  }
  
  OscMessage pwm0 = new OscMessage("/pwm0   ");
  pwm0.add(int(ch1.normValue * 1024));
  oscP5.send(pwm0, myOtraRemoteLocation);
  
  OscMessage pwm1 = new OscMessage("/pwm1");
  pwm1.add(int(ch2.normValue * 1024));
  oscP5.send(pwm1, myOtraRemoteLocation);
  
  OscMessage pwm2 = new OscMessage("/pwm2");
  pwm2.add(int(ch3.normValue * 1024));
  oscP5.send(pwm2, myOtraRemoteLocation);
  
  OscMessage pwm3 = new OscMessage("/pwm3");
  pwm3.add(int(ch4.normValue * 1024));
  oscP5.send(pwm3, myOtraRemoteLocation);
  
  println("1: " + ch1.value + " 2: " + ch2.value + " 3: + " + ch3.value + " 4: " + ch4.value);
  // println(int(ch4.normValue * 1024));
}
