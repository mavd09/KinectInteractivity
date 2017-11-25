/**
 * Kinect Interactivity using proscene
 * by Alan Jesus Navarro Montes, Manuel Alejandro Vergara Diaz.
 *
 * Press 'h' to display the key shortcuts and mouse bindings in the console.
 */

import remixlab.proscene.*;
import java.util.Map;
import remixlab.dandelion.geom.*;
import remixlab.bias.*;
import remixlab.bias.event.*;
import remixlab.dandelion.core.*;


import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

PShader shader;
PGraphics canvas;
Scene scene;
boolean original = true;
float posns[];
InteractiveFrame[] models;

int graphSize;

JSONObject json;
HashMap<Integer, Integer> colors;
HashMap<Integer, FloatList> groupCenter;

HIDAgent hidAgent;
static int SN_ID;

// Kinect Library object
KinectTrack kinectAgent;

Position rightHand, leftHand, currentEye;

float kinectDepthX = 320;
float kinectDepthY = 240;
float centerKinectDepthX = (kinectDepthX)/2;
float centerKinectDepthY = (kinectDepthY)/2;

float centerKinectDepthZ = 10500;
float handOffset = 50;
float handOffsetZ = 1000;


void setup() {
  size(600, 600, P3D);
  canvas = createGraphics(width, height, P3D);    
  scene = new Scene(this, (PGraphics3D) canvas);
  //colorMode(HSB, 255);
  
  colors = new HashMap<Integer, Integer>();
  groupCenter = new HashMap<Integer, FloatList>();
  
  json = loadJSONObject("graph1.json");
  JSONArray nodes = json.getJSONArray("nodes");
  
  graphSize = nodes.size();
  
  posns = new float[3*graphSize];
  models = new InteractiveFrame[graphSize];

  for (int i = 0; i < graphSize; i++) {
    JSONObject node = nodes.getJSONObject(i);
    
    models[i] = new InteractiveFrame(scene, drawNode(node.getInt("group")));
    generatePosition(i, node.getInt("group"));
    models[i].translate(posns[3*i], posns[3*i+1], posns[3*i+2]);
  }

  scene.setRadius(700);
  scene.showAll();

  shader = loadShader("depth.glsl");
  shader.set("maxDepth", scene.radius()*2);

  frameRate(1000);
  
  // Init Positions 
  rightHand = new Position();
  leftHand = new Position();
  currentEye = new Position();
  
  // Kinect specifics
  hidAgent = new HIDAgent(scene);
  kinectAgent = new KinectTrack(this);
  scene.eyeFrame().setMotionBinding(SN_ID, "translateRotateXYZ");
  
  kinectAgent.setUpBodyData();
}

void generatePosition(int node, int group) {
  if (groupCenter.get(group) == null) {
    FloatList tmp = new FloatList();
    float sceneR = 600;
    tmp.append(random(-sceneR, sceneR));
    tmp.append(random(-sceneR, sceneR));
    tmp.append(random(-sceneR, sceneR));
    groupCenter.put(group, tmp);
  }
  FloatList pos = groupCenter.get(group);
  float groupR = 100;
  posns[3*node]=pos.get(0) + random(-groupR, groupR);
  posns[3*node+1]=pos.get(1) + random(-groupR, groupR);
  posns[3*node+2]=pos.get(2) + random(-groupR, groupR);
}

void draw() {
  scene.beginDraw();
  background(0);
  pushMatrix();
  scene.drawFrames();

  scene.pg().pushStyle();
  scene.pg().colorMode(RGB, 255);
  scene.pg().strokeWeight(1);
  scene.pg().stroke(255, 166, 42);
  
  JSONArray links = json.getJSONArray("links");
  
  for (int i = 0; i < links.size(); i++) {
      int n1, n2;
      JSONObject current = (links.getJSONObject(i));
      n1 = current.getInt("source");
      n2 = current.getInt("target");
      //scene.pg().strokeWeight(current.getInt("value"));
      
      scene.pg().line(posns[3*n1], posns[3*n1+1], posns[3*n1+2], posns[3*n2], posns[3*n2+1], posns[3*n2+2]);
  }
  
  scene.pg().popStyle();
  popMatrix();
  scene.endDraw();
  scene.display();
  smooth();
  frameRate(1);
  
  
  image(kinectAgent.kinect.GetDepth(), 0, 0, kinectDepthX, kinectDepthY);
  
  drawSafeZone();
  for (int i=0; i<min(1, kinectAgent.bodies.size()); i++) {
    // Get right hand position
    rightHand.x = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).x * kinectDepthX;
    rightHand.y = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).y * kinectDepthY;
    rightHand.z = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).z;
    // Get left hand position
    leftHand.x = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).x * kinectDepthX;
    leftHand.y = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).y * kinectDepthY;
    leftHand.z = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).z;
    processKinectMovement();
  }
  
}

private void drawSafeZone() {
  strokeWeight(2);
  noFill();
  ellipse(centerKinectDepthX, centerKinectDepthY, handOffset*2, handOffset*2);
}

private void drawHandsHelpers() {
  fill(255, 0 ,0);
  noStroke();
  ellipse(rightHand.x, rightHand.y, 25, 25);
  fill(0, 255,0);
  ellipse(leftHand.x, leftHand.y, 25, 25);
} 

// processing rotation movement
public void processKinectMovement(){
  drawHandsHelpers();
  // Only process the changes where the hand is currently.
  currentEye = new Position();
  if (isInSafeZone(leftHand)) {
    processHandTranslation(rightHand);
  } else if(isInSafeZone(rightHand)) {
    processHandTranslation(leftHand);
  } else {
    // TODO: rotations
  }
  
}

private boolean isInSafeZone(Position hand){
  float dist = sqrt((centerKinectDepthX - hand.x)*(centerKinectDepthX - hand.x) + 
  (centerKinectDepthY - hand.y)*(centerKinectDepthY - hand.y));
  return dist <= handOffset;
}

private void processHandTranslation(Position hand) {
  float dist = sqrt((centerKinectDepthX - hand.x)*(centerKinectDepthX - hand.x) + 
  (centerKinectDepthY - hand.y)*(centerKinectDepthY - hand.y));
  float dx = 0.3;
   //processing translation
  if (dist > handOffset) {
    // X-axis
    if (hand.x > centerKinectDepthX + handOffset)
      currentEye.x = dx;
    if (hand.x < centerKinectDepthX - handOffset)
      currentEye.x = -dx;
    // Y-axis
    if (hand.y > centerKinectDepthY + handOffset)
      currentEye.y = dx;
    if (hand.y < centerKinectDepthY - handOffset)
      currentEye.y = -dx;
  }
}

PShape drawNode(int group) {
  PShape box = createShape(SPHERE, 20);
  box.setStroke(255);
  box.setFill(getColor(group));
  return box; 
}



color getColor(int group) {
  if (colors.get(group) != null) {
    return colors.get(group);
  }
  colors.put(group,color(random(0,255), random(0,255), random(0,255)));
  return colors.get(group);
}

void keyPressed() {
}

// kinect4WinSDK updating default methods
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(kinectAgent.bodies) {
    kinectAgent.bodies.add(_s);
  }
}


void disappearEvent(SkeletonData _s) 
{
  synchronized(kinectAgent.bodies) {
    for (int i=kinectAgent.bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID) 
      {
        kinectAgent.bodies.remove(i);
      }
    }
  }
}
 
void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(kinectAgent.bodies) {
    for (int i=kinectAgent.bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID) 
      {
        kinectAgent.bodies.get(i).copy(_a);
        break;
      }
    }
  }
}