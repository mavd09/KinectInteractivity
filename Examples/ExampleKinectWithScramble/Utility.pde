public static class Utility {
  
  public static float sqr( float value ) {
    return value*value;
  }
  
  public static float getDistance( float fromX, float fromY, float toX, float toY ) {
    return sqrt( sqr(fromX-toX) + sqr(fromY-toY) );
  }
  
}