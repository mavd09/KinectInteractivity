public class Position {
  float x, y, z;
  public Position() {
   x = 0.0; 
   y = 0.0;
   z = 0.0;
  }
  
  public void updatePosition(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}