public class HIDAgent extends Agent {
  // array of sensitivities that will multiply the sliders input
  // found pretty much as trial an error
  private Position currentTranslation, currentRotation;
  private float[] sens = { 4, 4, 7, 3, 5, 5 };
  
  public HIDAgent( Scene scene ) {
    super( scene.inputHandler() );
    currentTranslation = new Position();
    currentRotation = new Position();
    // SN_ID will be assigned an unique id with 6 DOF's. The id may be
    // used to bind (frame) actions to the gesture, pretty much in
    // the same way as it's done with the LEFT and RIGHT mouse gestures.
    SN_ID = MotionShortcut.registerID(6, "SN_SENSOR");
    addGrabber(scene.eyeFrame());
    setDefaultGrabber(scene.eyeFrame());
  }
  
  public void setCurrentTranslationX( float x ) {
    currentTranslation.x = x;
  }
  
  public void setCurrentTranslationY( float y ) {
    currentTranslation.y = y;
  }
  
  public void setCurrentTranslationZ( float z ) {
    currentTranslation.z = z;
  }
  
  public void setCurrentRotationX( float x ) {
    currentRotation.x = x;
  }
  
  public void setCurrentRotationY( float y ) {
    currentRotation.y = y;
  }
  
  public void setCurrentRotationZ( float z ) {
    currentRotation.z = z;
  }
  
  public void reset( ) {
    currentTranslation.reset();
    currentRotation.reset();
  }
  
  // we need to override the agent sensitivities method for the agent
  // to apply them to the input data gathered from the sliders
  @Override
  public float[] sensitivities( MotionEvent event ) {
    if( event instanceof DOF6Event ) {
      return sens;
    }
    return super.sensitivities(event);
  }
  
  // polling is done by overriding the feed agent method
  // note that we pass the id of the gesture
  @Override
  public DOF6Event feed( ) {
    return new DOF6Event(currentTranslation.x, currentTranslation.y, currentTranslation.z, currentRotation.x, currentRotation.y, currentRotation.z, BogusEvent.NO_MODIFIER_MASK, SN_ID);
  }
  
  public float[] getSens( ) {
    return this.sens; 
  }

  public void setSens( float[] sens ) {
    this.sens = sens;
  }

}