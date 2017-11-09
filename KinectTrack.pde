public class KinectTrack {
  Kinect kinect;
  ArrayList <SkeletonData> bodies;
  public static final int LEFT_HAND_ID = Kinect.NUI_SKELETON_POSITION_HAND_LEFT;
  public static final int RIGHT_HAND_ID = Kinect.NUI_SKELETON_POSITION_HAND_RIGHT;
  
  public KinectTrack(PApplet p){
    kinect = new Kinect(p);   
    println("left = " , Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
    println("right = ", Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
  }

  public void setUpBodyData(){
    bodies = new ArrayList<SkeletonData>();
  }  

  public PVector getLeftHandPosition(SkeletonData s){
    return s.skeletonPositions[LEFT_HAND_ID];
  }

  public PVector getRightHandPosition(SkeletonData s){
    return s.skeletonPositions[RIGHT_HAND_ID];
  }

  
}