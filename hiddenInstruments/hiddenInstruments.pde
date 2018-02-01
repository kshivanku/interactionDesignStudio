import org.openkinect.processing.*;
import netP5.*;
import oscP5.*;

Kinect2 kinect2;
OscP5 oscp5;

NetAddress myRemoteLocation;
int[] instruments = {0, 0, 0, 0, 0, 0, 0, 0};
int send;

float minThresh = 200;
float maxThresh = 1000;
float guitarMinThresh = 1010;
float guitarMaxThresh = 1800;

PImage img;

void setup() {
  size(512, 424);
  oscp5 = new OscP5 (this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 8000);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  send = 1;
}

void draw() {
  instruments[0] = 0;
  instruments[1] = 0;
  instruments[2] = 0;
  instruments[3] = 0;
  instruments[4] = 0;
  instruments[5] = 0;
  instruments[6] = 0;
  instruments[7] = 0;
  background(0);
  img.loadPixels();
  int[] depth = kinect2.getRawDepth();
  for(int x = 0 ; x < kinect2.depthWidth ; x++){
    for(int y = 0; y< kinect2.depthHeight ; y++) {
      int offset = x + y * kinect2.depthWidth;
      float dxy = depth[offset];
      
      if(dxy<maxThresh && dxy>minThresh) {
        img.pixels[offset] = color(255, 0, 150);
        if(x < width/2 && y < height/2) {
          instruments[0] += 1;
          //println("piano1");
        }
        else if(x > width/2 && y < height/2) {
          instruments[1] += 1;
          //println("piano2");
        }
        else if(x < width/2 && y > height/2) {
          instruments[2] += 1;
          //println("piano3");
        }
        else if(x > width/2 && y > height/2) {
          instruments[3] += 1;
          //println("piano4");
        }
      }
      else if(dxy<guitarMaxThresh && dxy>guitarMinThresh) {
        img.pixels[offset] = color(255, 0, 0);
        if(x < width/2 && y < height/2) {
          instruments[4] += 1;
          //println("guitar1");
        }
        else if(x > width/2 && y < height/2) {
          instruments[5] += 1;
          //println("guitar2");
        }
        else if(x < width/2 && y > height/2) {
          instruments[6] += 1;
          //println("guitar3");
        }
        else if(x > width/2 && y > height/2) {
          instruments[7] += 1;
          //println("guitar4");
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
  if(send > 50){
    send = 1;
    sendOSCMessage(instruments);
  }
}

 void sendOSCMessage(int[] instruments){
   int[] sendArray = {0, 0, 0, 0, 0, 0, 0, 0};
   println(instruments);
   for (int i=0; i < 8 ; i++) {
     if(instruments[i] > 1000) {
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