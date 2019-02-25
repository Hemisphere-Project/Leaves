import org.openkinect.processing.*;
import blobDetection.*;
import punktiert.math.*;
import punktiert.physics.*;
import processing.sound.*;

// Kinect       kinect;
Kinect2      kinect2;

VPhysics      physics;
BAttraction[] attractions = new BAttraction[] {};

PImage      img1;
PImage      img2;
PImage      img3;
PImage      img4;
PImage      img5;
PImage      img6;
PImage      img7;
PImage      img8;
PImage      img9;
PImage      img10;

PImage mask;
SoundFile soundfile;

int     numParticles          = 2000;
boolean configMode            = false;
boolean drawFilteredImage     = false;
long    lastUserInteraction   = 0;
boolean kinectConnected       = false;
int     maxVerticesPerBlob    = 50;
boolean useBlur               = false;
float   blobDetectionScale    = 0.3;      //  SCALE BLOB DETECTION (init 0.5)

// KINECT CONFIG
int     depthThresholdMin     = 200;     // NEAREST 200
int     depthThresholdMax     = 600;     // FAREST 600
boolean flipImage             = true;       // Flip image de caméra (pour éviter d'avoir à inverser la vidéoprojection)
// KINECT MAPPING
int     xMin                  = 10;
int     yMin                  = 20;
int     xMax                  = 1820;
int     yMax                  = 1050;


// MECANICS
float   friction              = 0.1;        // how much friction each particle has
int     dotSize               = 20;         // dot size
float   dotMass               = 2.5;        // dot Mass 1:SLOW (heavy) 10:FAST (léger)
int     homeSize              = 4;          // home size
int     homeMass              = 100;        // home Mass      100

float   homeSpringStrength    = 0.0001f;    // the force drawing the particles back to their home position

int     imgZoomOut = 8;


////////////////////////////////////////////////////
/////////////////////// SETUP //////////////////////
////////////////////////////////////////////////////

public void setup() {

  // size(1920,1080);
  fullScreen(P3D);
  noCursor();
  frameRate(25);

  // INITIALISE KINECT
  // kinect V1
  // kinect = new Kinect(this);
  // kinect.initDepth();
  // kinectConnected = true;
  // kinect V2
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  if (kinect2.getNumKinects() > 0) { kinectConnected = true;}

  setupPhysics();

  img1 = loadImage("files/a1.png");
  img2 = loadImage("files/a2.png");
  img3 = loadImage("files/a3.png");
  img4 = loadImage("files/a4.png");
  img5 = loadImage("files/a5.png");
  img6 = loadImage("files/a6.png");
  img7 = loadImage("files/a7.png");
  img8 = loadImage("files/a8.png");
  img9 = loadImage("files/a9.png");
  img10 = loadImage("files/a10.png");
  img1.resize(img1.width/imgZoomOut, img1.height/imgZoomOut);
  img2.resize(img2.width/imgZoomOut, img2.height/imgZoomOut);
  img3.resize(img3.width/imgZoomOut, img3.height/imgZoomOut);
  img4.resize(img4.width/imgZoomOut, img4.height/imgZoomOut);
  img5.resize(img5.width/imgZoomOut, img5.height/imgZoomOut);
  img6.resize(img6.width/imgZoomOut, img6.height/imgZoomOut);
  img7.resize(img7.width/imgZoomOut, img7.height/imgZoomOut);
  img8.resize(img8.width/imgZoomOut, img8.height/imgZoomOut);
  img9.resize(img9.width/imgZoomOut, img9.height/imgZoomOut);
  img10.resize(img10.width/imgZoomOut, img10.height/imgZoomOut);

  // MASK
  mask = loadImage("files/mask.png");
  mask.resize(width,height);

  // SOUND
  soundfile = new SoundFile(this, "files/sound.aif");
  soundfile.loop();

}


private void setupPhysics() {

  physics = new VPhysics();
  physics.setfriction(friction);


  for (int x = 0; x < numParticles; x++) {
      // RANDOM REPARTITION
      /////////////////////////////////
      // float px = random(0, width);
      // float py = random(0,height);
      // ELLIPSE REPARTITION
      /////////////////////////////////
      // float randomAngle = random(0, 2*PI);
      // float randomRadiusX = random(25, width/2+100);
      // float randomRadiusY = random(25, height/2+100);
      // float px = width/2 + cos(randomAngle)* randomRadiusX ;
      // float py = height/2 + sin(randomAngle)* randomRadiusY ;
      // 1/4 ELLIPSE REPARTITION
      /////////////////////////////////
      // float randomAngle = random(3*PI/2, 2*PI);
      // float randomRadiusX = random(25, width);
      // float randomRadiusY = random(25, height);
      // float px = 0 + cos(randomAngle)* randomRadiusX ;
      // float py = height + sin(randomAngle)* randomRadiusY ;
      // 1/4 ELLIPSE REPARTITION (BIGGER)
      /////////////////////////////////
      float randomAngle = random((3*PI/2)+0.3, 2*PI-0.3);
      float randomRadiusX = pow(random(25, width-200),1.01);
      float randomRadiusY = pow(random(25, height-200),1.01);
      if( randomAngle>(PI/8+3*PI/2) && randomAngle<(2*PI-PI/8) ){
        randomRadiusX = pow(random(25, width+200),1.01);
        randomRadiusY = pow(random(25, height+200),1.01);
      }
      float px = 0 + cos(randomAngle)* randomRadiusX ;
      float py = height - 20 + sin(randomAngle)* randomRadiusY ;
      /////////////////////////////////
      //HOME
      Vec homePos    = new Vec(int(px), int(py));
      VParticle home = new VParticle(homePos, homeMass, homeSize);
      home.lock();
      // MASS RANDOM
      float randomMass = random(dotMass, dotMass+1);
      // DOT
      VParticle dot  = new VParticle(homePos, randomMass, dotSize);
      // COLLISION
      // dot.addBehavior(new BCollision());
      // ADD
      physics.addParticle(dot);
      physics.addSpring(new VSpringRange(home, dot, 0, 0, homeSpringStrength));
  }

}

////////////////////////////////////////////////////
/////////////////////// DRAW ///////////////////////
////////////////////////////////////////////////////

public void draw() {

  background(0);

  if (kinectConnected) {
    // THRESHOLD IMG
    DepthFilter depthFilter = new DepthFilter(depthThresholdMin, depthThresholdMax, flipImage);
    // RAWDEPTH
    // kinect V1
    // PImage filteredImage = depthFilter.filteredImage(kinect.getRawDepth(), 640, 480);
    // kinect V2
    PImage filteredImage = depthFilter.filteredImage(kinect2.getRawDepth(), kinect2.depthWidth, kinect2.depthHeight);
    // DETECT BLOBS
    Detector detector = new Detector((int)(filteredImage.width * blobDetectionScale), (int)(filteredImage.height * blobDetectionScale), maxVerticesPerBlob);
    detector.detectBlobs(filteredImage);
    // if (detector.blobs.size() > 0) { lastUserInteraction = System.currentTimeMillis(); }
    if (configMode) {
      detector.drawBlobs();
      if(drawFilteredImage){
        image(filteredImage,xMin, yMin, xMax-xMin, yMax-yMin);
      }

    }
    // INJECT BLOBS
    injectAttractions(detector.makePunktiertAttractions());
  }


  physics.update();

  // now draw the actual dots
  for (VParticle p : physics.particles) {

    // Vec velocity = p.getVelocity();
    // int radius = Math.min((int)p.getRadius(), dotSize-1);
    float mass = p.getWeight();

    if((mass>(dotMass+0.0))&&(mass<=(dotMass+0.1))){
      image(img1, p.x, p.y);
      // Rotation -- Attention coute en FPS
      // pushMatrix(); translate(p.x,p.y); rotate(mass%(0.1)*PI/0.1); translate(-radius/2,-radius/2); image(img1, 0,0); popMatrix();
    }else if((mass>(dotMass+0.1))&&(mass<=(dotMass+0.2))){
      image(img2, p.x, p.y);
    }else if((mass>(dotMass+0.2))&&(mass<=(dotMass+0.3))){
      image(img3, p.x, p.y);
    }else if((mass>(dotMass+0.3))&&(mass<=(dotMass+0.4))){
      image(img4, p.x, p.y);
    }else if((mass>(dotMass+0.4))&&(mass<=(dotMass+0.5))){
      image(img5, p.x, p.y);
    }else if((mass>(dotMass+0.5))&&(mass<=(dotMass+0.6))){
      image(img6, p.x, p.y);
    }else if((mass>(dotMass+0.6))&&(mass<=(dotMass+0.7))){
      image(img7, p.x, p.y);
    }else if((mass>(dotMass+0.7))&&(mass<=(dotMass+0.8))){
      image(img8, p.x, p.y);
    }else if((mass>(dotMass+0.8))&&(mass<=(dotMass+0.9))){
      image(img9, p.x, p.y);
    }else if((mass>(dotMass+0.9))&&(mass<=(dotMass+1.0))){
      image(img10, p.x, p.y);
    }

  }

  // image(mask, 0, 0);

  // CONFIG DISPLAY
  if (configMode) {
    fill(40,40,40);
    stroke(40,40,40);
    rect(0,0,230,height);
    fill(255);
    text("CONFIG MODE",20,40);
    text("FPS : "+frameRate,20,60);

    text("CAMERA MAPPING",20,100);
    text( "xMin - yMin // w // ←↑↓→",20,120);
    text(xMin+" - "+yMin,20,140);
    text("xMax - yMax // x // ←↑↓→",20,160);
    text(xMax+" - "+yMax,20,180);

    text("DEPTH THRESHOLDS MIN & MAX",20,220);
    text( "Distance Min // q // ↑↓",20,240);
    text(depthThresholdMin,20,260);
    text( "Distance Max // s // ↑↓ ",20,280);
    text(depthThresholdMax,20,300);


    text("Draw Filtered Img // v // "+drawFilteredImage,20,340);


  }


} // End Draw


// INJECT ATTRACTIONS
// Remove the prevous + Add New ones
private void injectAttractions(BAttraction[] newAttractions) {
  physics.behaviors.clear();
  for (BAttraction attraction : newAttractions) {
    physics.addBehavior(attraction);
  }
}


////////////////////////////////////////////////////
/////////////////////// DRAW ///////////////////////
////////////////////////////////////////////////////

boolean minThreshEdit = false;
boolean maxThreshEdit = false;
boolean minPosEdit = false;
boolean maxPosEdit = false;

void allEditsFalse(){
  minThreshEdit = false;
  maxThreshEdit = false;
  minPosEdit = false;
  maxPosEdit = false;
}

public void keyPressed() {

  // ENTER CONFIG MODE
  if (key == 'c') {
    configMode = !configMode;
    allEditsFalse();
  }

  if (configMode){
    // Selector
    if (key =='q'){ allEditsFalse(); minThreshEdit = true; }
    else if (key =='s'){ allEditsFalse(); maxThreshEdit = true; }
    else if (key =='w'){ allEditsFalse(); minPosEdit = true; }
    else if (key =='x'){ allEditsFalse(); maxPosEdit = true; }
    // Depth Treshold min
    if (minThreshEdit) {
      if (keyCode == UP) { depthThresholdMin +=10; }
      else if (keyCode == DOWN) { depthThresholdMin -=10; }
    }
    // Depth Treshold max
    if (maxThreshEdit) {
      if (keyCode == UP) { depthThresholdMax +=10; }
      else if (keyCode == DOWN) { depthThresholdMax -=10; }
    }
    // Camera Mapping - Min
    if (minPosEdit) {
      if (keyCode == UP) { yMin -=10; }
      else if (keyCode == DOWN) { yMin +=10; }
      else if (keyCode == LEFT) { xMin -=10; }
      else if (keyCode == RIGHT){ xMin +=10; }
    }
    // Camera Mapping - Max
    if (maxPosEdit) {
      if (keyCode == UP) { yMax -=10; }
      else if (keyCode == DOWN) { yMax +=10; }
      else if (keyCode == LEFT) { xMax -=10; }
      else if (keyCode == RIGHT){ xMax +=10; }
    }
    // Draw filtered image
    if (key == 'v') {
      drawFilteredImage = !drawFilteredImage;
    }
  }

}
