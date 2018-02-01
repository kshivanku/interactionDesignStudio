import org.openkinect.processing.*;
import netP5.*;
import oscP5.*;

Kinect2 kinect2;
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

float brightThresh = 800;

PImage img;
PImage currentFrame;
PImage prevFrame;


void setup() {
  size(512, 424);
  oscp5 = new OscP5 (this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 8000);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  currentFrame = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  prevFrame = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  send = 1;
}

void draw() {
  prevFrame.copy(currentFrame, 0 , 0, currentFrame.width, currentFrame.height, 0, 0, prevFrame.width, prevFrame.height);
  prevFrame.updatePixels();
  currentFrame = kinect2.getDepthImage();
  prevFrame.loadPixels();
  currentFrame.loadPixels();
  img.loadPixels();
  resetInstruments();
  background(0);
  int[] depth = kinect2.getRawDepth();
  for(int x = 0 ; x < kinect2.depthWidth ; x++){
    for(int y = 0; y< kinect2.depthHeight ; y++) {
      int offset = x + y * kinect2.depthWidth;
      float dxy = depth[offset];
      float b1 = brightness(currentFrame.pixels[offset]);
      float b2 = brightness(prevFrame.pixels[offset]);
      float brightDiff = (b1 - b2) * (b1 - b2);
      if(brightDiff > brightThresh && dxy > minThresh11 && dxy < maxThresh42) {
        if(dxy>minThresh11 && dxy<maxThresh12) {
          if(x<width/2){
            img.pixels[offset] = color(236, 18, 18); //red
            instruments[0] += 1;
          }
          else{
            img.pixels[offset] = color(153, 6, 6); //dark red
            instruments[1] += 1;
          }
        }
        else if(dxy>minThresh21 && dxy<maxThresh22){
          if(x<width/2){
            img.pixels[offset] = color(255, 0, 150); //pink
            instruments[2] += 1;
          }
          else{
            img.pixels[offset] = color(128, 0, 212); //purple
            instruments[3] += 1;
          }
        }
        else if(dxy>minThresh31 && dxy<maxThresh32){
          if(x<width/2){
            img.pixels[offset] = color(0, 32, 194); //dark blue 
            instruments[4] += 1;
          }
          else{
            img.pixels[offset] = color(0, 136, 222); //light blue
            instruments[5] += 1;
          }
        }
        else if(dxy>minThresh41 && dxy<maxThresh42) {
          if(x<width/2){
            img.pixels[offset] = color(0, 200, 14); //green
            instruments[6] += 1;
          }
          else{
            img.pixels[offset] = color(105, 211, 11); //light green
            instruments[7] += 1;
          }
        }
      }
      else {
        img.pixels[offset] = currentFrame.pixels[offset];
      }
   }
  }
  img.updatePixels();
  image(img, 0, 0);
  send += 1;
  if(send > 20){
    send = 1;
    sendOSCMessage(instruments);
  }
}

 void sendOSCMessage(int[] instruments){
   int[] sendArray = {0, 0, 0, 0, 0, 0, 0, 0};
   //println(instruments);
   for (int i=0; i < instruments.length ; i++) {
     if(instruments[i] > 300) {
       sendArray[i] = 1;
     }
     else {
       sendArray[i] = 0;
     }
   }
   //println(sendArray);
    OscMessage myMessage = new OscMessage("");
    myMessage.add(sendArray);
    oscp5.send(myMessage, myRemoteLocation);
  }
  
  void resetInstruments(){
    println(instruments);
    for (int i=0 ; i<instruments.length ; i++){
      if(instruments[i] > 100){
        instruments[i] -= 100;
      }
      else {
        instruments[i] = 0;
      }
    }
  }