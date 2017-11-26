public class Position {
  
  private float x;
  private float y;
  private float z;
  
  public Position( ) {
    reset();
  }
  
  public Position( float x, float y, float z ) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public void reset( ) {
    x = 0.0; 
    y = 0.0;
    z = 0.0;
  }

}