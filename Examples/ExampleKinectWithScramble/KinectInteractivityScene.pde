import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

static int SN_ID;
private KinectTrack kinectAgent;

public class KinectInteractivityScene {
  
  final static float DEFAULT_WIDTH_KINECT_SCREEN = 320;
  final static float DEFAULT_HEIGHT_KINECT_SCREEN = 240;
  final static float DEFAULT_HAND_OFFSET = 60;
  final static float DEFAULT_DELTA = 0.3;
  
  final static color LEFT_HAND_COLOR = #CC0000;
  final static color RIGHT_HAND_COLOR = #66CC00;
  
  final static float SIZE_HAND_HELPER = 40;
  final static float DELTA_HAND_HELPER = 5.0;
  
  private float widthKinectScreen = DEFAULT_WIDTH_KINECT_SCREEN;
  private float heightKinectScreen = DEFAULT_HEIGHT_KINECT_SCREEN;
  
  private float centerKinectScreenX = DEFAULT_WIDTH_KINECT_SCREEN/2.0;
  private float centerKinectScreenY = DEFAULT_HEIGHT_KINECT_SCREEN/2.0;
  
  private float handOffset = DEFAULT_HAND_OFFSET;
  private float offsetZ = 1000;
  private float offsetRotation = 3000;
  
  private float delta = DEFAULT_DELTA;
  
  private HIDAgent hidAgent;  
  private Position rightHand, leftHand;
  
  public KinectInteractivityScene( Scene scene ) {
    // Init Positions 
    rightHand = new Position();
    leftHand = new Position();
    // Kinect specifics
    hidAgent = new HIDAgent(scene);
    kinectAgent = new KinectTrack(scene.pApplet());
    scene.eyeFrame().setMotionBinding(SN_ID, "translateRotateXYZ");
    kinectAgent.setUpBodyData();
  }
  
  public KinectInteractivityScene( Scene scene, float widthKinectScreen, float heightKinectScreen ) {
    this(scene);
    this.widthKinectScreen = widthKinectScreen;
    this.heightKinectScreen = heightKinectScreen;
    centerKinectScreenX = widthKinectScreen/2.0;
    centerKinectScreenY = heightKinectScreen/2.0;
  }
  
  public void process() {
    drawKinectScreen();
    drawSafeZone();
    drawRotationZones();
    for( int i = 0; i < min( 1, kinectAgent.bodies.size() ); i++ ) {
      // Get right hand position
      rightHand.x = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).x * widthKinectScreen;
      rightHand.y = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).y * heightKinectScreen;
      rightHand.z = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).z;
      // Get left hand position
      leftHand.x = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).x * widthKinectScreen;
      leftHand.y = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).y * heightKinectScreen;
      leftHand.z = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).z;
      processKinectMovement();
    }
  }
  
  private void drawKinectScreen() {
    scene.beginScreenDrawing();
    pushStyle();
    stroke(0, 0, 255);
    strokeWeight(5);
    noFill();
    rectMode(CORNERS);
    rect(0, 0, widthKinectScreen, heightKinectScreen);
    image(kinectAgent.kinect.GetDepth(), 0, 0, widthKinectScreen, heightKinectScreen);
    popStyle();
    scene.endScreenDrawing();
  }
  
  private void drawSafeZone() {
    scene.beginScreenDrawing();
    pushStyle();
    stroke(0, 0, 255);
    strokeWeight(2);
    noFill();
    ellipse(centerKinectScreenX, centerKinectScreenY, handOffset*2, handOffset*2);
    popStyle();
    scene.endScreenDrawing();
  }
  
  private void drawRotationZones() {
    scene.beginScreenDrawing();
    pushStyle();
    stroke(0, 0, 255);
    strokeWeight(2);
    noFill();
    rect(0, centerKinectScreenY - handOffset, widthKinectScreen, handOffset*2);
    rect(centerKinectScreenX - handOffset, 0, handOffset*2, heightKinectScreen);
    popStyle();
    scene.endScreenDrawing();
  }
  
  private void drawHandsHelpers() {
    scene.beginScreenDrawing();
    pushStyle();
    noStroke();
    fill(RIGHT_HAND_COLOR);
    float scaleRightHand = 1.0 + (10000-rightHand.z)/offsetZ/DELTA_HAND_HELPER;
    ellipse( rightHand.x, rightHand.y, SIZE_HAND_HELPER*scaleRightHand, SIZE_HAND_HELPER*scaleRightHand );
    fill(LEFT_HAND_COLOR);
    float scaleLeftHand = 1.0 + (10000-leftHand.z)/offsetZ/DELTA_HAND_HELPER;
    ellipse( leftHand.x, leftHand.y, SIZE_HAND_HELPER*scaleLeftHand, SIZE_HAND_HELPER*scaleLeftHand );
    popStyle();
    scene.endScreenDrawing();
  } 
  
  // processing rotation movement
  public void processKinectMovement(){
    drawHandsHelpers();
    // Only process the changes where the hand is currently.
    hidAgent.reset( );
    if (isInSafeZone(leftHand)) {
      if (isInSafeZone(rightHand)) {
        processZoom();
      } else {
        processHandTranslation(rightHand);
      }
    } else if(isInSafeZone(rightHand)) {
      processHandTranslation(leftHand);
    } else {
      processRotation();
    }
  }
  
  private boolean isInRotationXZone(Position hand){
    return hand.y > centerKinectScreenY - handOffset && hand.y < centerKinectScreenY + handOffset;
  }
  
  private boolean isInRotationYZone(Position hand) {
    return hand.x > centerKinectScreenX - handOffset && hand.x < centerKinectScreenX + handOffset;
  }
  
  private void processRotation( ) {
    if (isInRotationXZone(leftHand) && isInRotationXZone(rightHand)) {
      hidAgent.setCurrentRotationY(getRotationValue());
    } else if (isInRotationYZone(leftHand) && isInRotationYZone(rightHand)) {
      hidAgent.setCurrentRotationX(getRotationValue());
    } else {
      hidAgent.setCurrentRotationZ(getRotationValue());
    }
  }
  
  private float getRotationValue( ) {
    float rightZ = rightHand.z;
    float leftZ = leftHand.z;
    float dist = abs(rightZ - leftZ);
    if (dist > offsetRotation) {
      if (rightZ < leftZ) {
        return delta;
      } else {
        return -delta;
      }
    }
    return 0;
  }
  
  private void processZoom( ) {
    if (rightHand.z > leftHand.z + offsetZ) {
      hidAgent.setCurrentTranslationZ( -delta );
    }
    if (rightHand.z < leftHand.z - offsetZ) {
      hidAgent.setCurrentTranslationZ( delta );
    }
  }
  
  private void processHandTranslation(Position hand) {
    float dist = Utility.getDistance( centerKinectScreenX, centerKinectScreenY, hand.x, hand.y );
     //processing translation
    if (dist > handOffset) {
      // X-axis
      if (hand.x > centerKinectScreenX + handOffset)
        hidAgent.setCurrentTranslationX( delta );
      if (hand.x < centerKinectScreenX - handOffset)
        hidAgent.setCurrentTranslationX( -delta );
      // Y-axis
      if (hand.y > centerKinectScreenY + handOffset)
        hidAgent.setCurrentTranslationY( delta );
      if (hand.y < centerKinectScreenY - handOffset)
        hidAgent.setCurrentTranslationY( -delta );
    }
  }
  
  private boolean isInSafeZone( Position hand ) {
    float dist = Utility.getDistance( centerKinectScreenX, centerKinectScreenY, hand.x, hand.y );
    return ( dist <= handOffset );
  }
  
}

// kinect4WinSDK updating default methods
void appearEvent( SkeletonData _s ) {
  if( _s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED ) {
    return ;
  }
  synchronized( kinectAgent.bodies ) {
    kinectAgent.bodies.add(_s);
  }
}

void disappearEvent( SkeletonData _s ) {
  synchronized( kinectAgent.bodies ) {
    for( int i = kinectAgent.bodies.size()-1; i >= 0; i-- ) {
      if( _s.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID ) {
        kinectAgent.bodies.remove(i);
      }
    }
  }
}
 
void moveEvent( SkeletonData _b, SkeletonData _a ) {
  if( _a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED ) {
    return ;
  }
  synchronized( kinectAgent.bodies ) {
    for( int i = kinectAgent.bodies.size()-1; i >= 0; i-- ) {
      if( _b.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID ) {
        kinectAgent.bodies.get(i).copy(_a);
        break;
      }
    }
  } 
}