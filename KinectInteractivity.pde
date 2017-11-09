/**
 * Knowledge Graph vizualization tool.
 * by Alan Jesus Navarro Montes.
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

float rightHandX = 0;
float rightHandY = 0;
float rightHandZ = 0;

float leftHandX = 0;
float leftHandY = 0;
float leftHandZ = 0;

float kinectDepthX = 320;
float kinectDepthY = 240;
float centerKinectDepthX = (kinectDepthX)/2;
float centerKinectDepthY = (kinectDepthY)/2;

float centerKinectDepthZ = 10500;
float handOffset = 50;
float handOffsetZ = 1000;

float currentPositionX = 0;
float currentPositionY = 0;
float currentPositionZ = 0;


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
  for (int i=0; i<kinectAgent.bodies.size (); i++) 
  {
    
    rightHandX = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).x * kinectDepthX;
    rightHandY = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).y * kinectDepthY;
    
    leftHandX = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).x * kinectDepthX;
    leftHandY = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).y * kinectDepthY;
    
    processKinectHand(rightHandX, rightHandY);
    //processKinectHand(leftHandX, leftHandY);
  }
  
}

// processing rotation movement
public void processKinectHand(float x , float y){
  
  strokeWeight(2);
  noFill();
  ellipse(centerKinectDepthX, centerKinectDepthY, handOffset*2, handOffset*2);
  fill(255, 0 ,0);
  noStroke();
  ellipse(x, y, 25, 25);
  
  float dist = sqrt((centerKinectDepthX - x)*(centerKinectDepthX - x) + (centerKinectDepthY - y)*(centerKinectDepthY - y));
  
  float dx = 0.3;
  currentPositionX = 0.0;
  currentPositionY = 0.0;
   //processing x translatation
  if (dist > handOffset) {
    
    if (x > centerKinectDepthX + handOffset)
      currentPositionX = dx;
    if (x < centerKinectDepthX - handOffset)
      currentPositionX = -dx;
      
    if (y > centerKinectDepthY + handOffset)
      currentPositionY = dx;
    if (y < centerKinectDepthY - handOffset)
      currentPositionY = -dx;
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