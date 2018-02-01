import org.openkinect.processing.*;
import netP5.*;
import oscP5.*;

Kinect kinect;
OscP5 oscp5;

NetAddress myRemoteLocation;
int[] instruments = {0, 0, 0, 0, 0, 0, 0, 0};
int send;

float minThresh11 = 100;
float maxThresh12 = 600;
float minThresh21 = 610;
float maxThresh22 = 1100;
float minThresh31 = 1110;
float maxThresh32 = 1700;
float minThresh41 = 1701;
float maxThresh42 = 2400;

PImage img;

void setup() {
  size(512, 424);
  oscp5 = new OscP5 (this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 8000);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.activateDevice(0);
  img = createImage(kinect.width, kinect.height, RGB);
  send = 1;
}

void draw() {
  img.loadPixels();
  resetInstruments();
  background(0);
  int[] depth = kinect.getRawDepth();
  for(int x = 0 ; x < kinect.width ; x++){
    for(int y = 0; y< kinect.height ; y++) {
      int offset = x + y * kinect.width;
      float dxy = depth[offset];
      if(dxy>minThresh11 && dxy<maxThresh12) {
          if(x<width/2){
            img.pixels[offset] = color(255, 255, 255);
            instruments[0] += 1;
          }
          else{
            img.pixels[offset] = color(150, 150, 150);
            instruments[1] += 1;
          }
      }
      else if(dxy>minThresh21 && dxy<maxThresh22){
        if(x<width/2){
          img.pixels[offset] = color(255, 0, 150);
          instruments[2] += 1;
        }
        else{
          img.pixels[offset] = color(255, 0, 200);
          instruments[3] += 1;
        }
      }
      else if(dxy>minThresh31 && dxy<maxThresh32){
        if(x<width/2){
          img.pixels[offset] = color(150, 0, 255);
          instruments[4] += 1;
        }
        else{
          img.pixels[offset] = color(200, 0, 255);
          instruments[5] += 1;
        }
      }
      else if(dxy>minThresh41 && dxy<maxThresh42) {
        if(x<width/2){
          img.pixels[offset] = color(0, 255, 255);
          instruments[6] += 1;
        }
        else{
          img.pixels[offset] = color(0, 255, 150);
          instruments[7] += 1;
        }
      }
      else {
        img.pixels[offset] = color(0, 0, 0);
      }
    }
  }
  img.updatePixels();
  image(img, 0, 0);
  //println(instruments);
  send += 1;
  if(send > 20){
    send = 1;
    sendOSCMessage(instruments);
  }
}

 void sendOSCMessage(int[] instruments){
   int[] sendArray = {0, 0, 0, 0, 0, 0, 0, 0};
   println(instruments);
   for (int i=0; i < instruments.length ; i++) {
     if(instruments[i] > 10000) {
       sendArray[i] = 1;
     }
     else {
       sendArray[i] = 0;
     }
   }
   println(sendArray);
    //create our OSC Message
    OscMessage myMessage = new OscMessage("");
    myMessage.add(sendArray);    
    //Send our message
    oscp5.send(myMessage, myRemoteLocation);
  }
  
  void resetInstruments(){
  for (int i=0 ; i<instruments.length ; i++){
    if(instruments[i] > 0){
      instruments[i] = 0;
    }
    else {
      instruments[i] = 0;
    }
  }
  }