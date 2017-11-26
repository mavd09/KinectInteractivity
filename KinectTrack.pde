public class KinectTrack {
  
  public static final int LEFT_HAND_ID = Kinect.NUI_SKELETON_POSITION_HAND_LEFT;
  public static final int RIGHT_HAND_ID = Kinect.NUI_SKELETON_POSITION_HAND_RIGHT;
  
  Kinect kinect;
  ArrayList<SkeletonData> bodies;
  
  public KinectTrack( PApplet p ) {
    kinect = new Kinect(p);
  }

  public void setUpBodyData( ) {
    bodies = new ArrayList<SkeletonData>();
  }  

  public PVector getLeftHandPosition( SkeletonData s ) {
    return s.skeletonPositions[LEFT_HAND_ID];
  }

  public PVector getRightHandPosition( SkeletonData s ) {
    return s.skeletonPositions[RIGHT_HAND_ID];
  }

  
}