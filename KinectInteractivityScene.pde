public class KinectInteractivityScene {
  
  final static float DEFAULT_WIDTH_KINECT_SCREEN = 320;
  final static float DEFAULT_HEIGHT_KINECT_SCREEN = 240;
  
  private float widthKinectScreen = DEFAULT_WIDTH_KINECT_SCREEN;
  private float heightKinectScreen = DEFAULT_HEIGHT_KINECT_SCREEN;
  
  private float centerKinectScreenX = DEFAULT_WIDTH_KINECT_SCREEN/2.0;
  private float centerKinectScreenY = DEFAULT_HEIGHT_KINECT_SCREEN/2.0;
  
  private float handOffset = 50;
  private float offsetZ = 1000;
  
  private float delta = 0.3;
  
  private KinectTrack kinectAgent;
  private HIDAgent hidAgent;  
  private Position rightHand, leftHand;
  
  public KinectInteractivityScene( KinectTrack kinectAgent, HIDAgent hidAgent ) {
    // Init Positions 
    rightHand = new Position();
    leftHand = new Position();
    
    this.kinectAgent = kinectAgent;
    this.hidAgent = hidAgent;
  }
  
  public KinectInteractivityScene( KinectTrack kinectAgent, HIDAgent hidAgent, float widthKinectScreen, float heightKinectScreen ) {
    this( kinectAgent, hidAgent );
    
    this.widthKinectScreen = widthKinectScreen;
    this.heightKinectScreen = heightKinectScreen;
    
    centerKinectScreenX = widthKinectScreen/2.0;
    centerKinectScreenY = heightKinectScreen/2.0;
  }
  
  public void process() {
    image(kinectAgent.kinect.GetDepth(), 0, 0, centerKinectScreenX, centerKinectScreenY);
    drawSafeZone();
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
  
  private void drawHandsHelpers() {
    pushStyle();
    fill(255, 0 ,0);
    noStroke();
    ellipse( rightHand.x, rightHand.y, 25, 25 );
    fill(0, 255,0);
    ellipse( leftHand.x, leftHand.y, 25, 25 );
    popStyle();
  } 
  
  // processing rotation movement
  public void processKinectMovement(){
    drawHandsHelpers();
    // Only process the changes where the hand is currently.
    hidAgent.setCurrentEye( new Position() );
    if (isInSafeZone(leftHand)) {
      if (isInSafeZone(rightHand)) {
        processZoom();
      } else {
        processHandTranslation(rightHand);
      }
    } else if(isInSafeZone(rightHand)) {
      processHandTranslation(leftHand);
    } else {
      // TODO: rotations
    }
    
  }
  
  private void processZoom(){
    float initialZ = leftHand.z;
    float z = rightHand.z;
    if (z > initialZ + offsetZ) {
      hidAgent.setCurrentEyeZ( -delta );
    }
    if (z < initialZ - offsetZ) {
      hidAgent.setCurrentEyeZ( delta );
    }
  }
  
  private void processHandTranslation(Position hand) {
    float dist = Utility.getDistance( centerKinectScreenX, centerKinectScreenY, hand.x, hand.y );
     //processing translation
    if (dist > handOffset) {
      // X-axis
      if (hand.x > centerKinectScreenX + handOffset)
        hidAgent.setCurrentEyeX( delta );
      if (hand.x < centerKinectScreenX - handOffset)
        hidAgent.setCurrentEyeX( -delta );
      // Y-axis
      if (hand.y > centerKinectScreenY + handOffset)
        hidAgent.setCurrentEyeY( delta );
      if (hand.y < centerKinectScreenY - handOffset)
        hidAgent.setCurrentEyeY( -delta );
    }
  }
  
  private void drawSafeZone() {
    pushStyle();
    strokeWeight(2);
    noFill();
    ellipse(centerKinectScreenX, centerKinectScreenY, handOffset*2, handOffset*2);
    popStyle();
  }
  
  private boolean isInSafeZone( Position hand ) {
    float dist = Utility.getDistance( centerKinectScreenX, centerKinectScreenY, hand.x, hand.y );
    return ( dist <= handOffset );
  }
  
}