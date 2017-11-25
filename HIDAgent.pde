public class HIDAgent extends Agent {
  // array of sensitivities that will multiply the sliders input
  // found pretty much as trial an error
  Position currentEye;
  float [] sens = {4, 4, 7, 0, 5, 5};
  
  public HIDAgent(Scene scn) {
    super(scn.inputHandler());
    currentEye = new Position();
    // SN_ID will be assigned an unique id with 6 DOF's. The id may be
    // used to bind (frame) actions to the gesture, pretty much in
    // the same way as it's done with the LEFT and RIGHT mouse gestures.
    SN_ID = MotionShortcut.registerID(6, "SN_SENSOR");
    addGrabber(scene.eyeFrame());
    setDefaultGrabber(scene.eyeFrame());
  }
  
  public void setCurrentEye(Position currentEye) {
    this.currentEye = currentEye;
  }
  
  public void setCurrentEyeX(float x) {
    currentEye.x = x;
  }
  
  public void setCurrentEyeY(float y) {
    currentEye.y = y;
  }
  
  public void setCurrentEyeZ(float z) {
    currentEye.z = z;
  }
  
  // we need to override the agent sensitivities method for the agent
  // to apply them to the input data gathered from the sliders
  @Override
  public float[] sensitivities(MotionEvent event) {
    if (event instanceof DOF6Event)
      return sens;
    else
      return super.sensitivities(event);
  }
  
  // polling is done by overriding the feed agent method
  // note that we pass the id of the gesture
  @Override
  public DOF6Event feed() {
    return new DOF6Event(currentEye.x, currentEye.y, currentEye.z, 0, 0, 0, BogusEvent.NO_MODIFIER_MASK, SN_ID);
  }
  
  public float[] getSens(){
    return this.sens; 
  }

  public void setSens(float[] sens){
    this.sens = sens;
  }

}