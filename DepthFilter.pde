/**
 * A simple class that takes a collection of raw Kinect depths, and creates a
 * black/white image based on the depths. Anything further away that the
 * threshold will be black, otherwise it will be white
 */
public class DepthFilter {
  /** Anything further away from this will be black, closer will be white */
  private int thresholdMin;
  private int thresholdMax;
  private boolean flipImage;

  public DepthFilter(int tMin, int tMax, boolean flip) {
    thresholdMin = tMin;
    thresholdMax = tMax;
    flipImage = flip;
  }

  /**
   * Creates an image based on the passed depths where distant pixels will
   * be black and close pixels will be white
   */
  public PImage filteredImage(int[] rawDepths, int rawWidth, int rawHeight) {
    PImage output = createImage(rawWidth, rawHeight, RGB);


    for (int x = 0; x < rawWidth; x++) {
      for (int y = 0; y < rawHeight; y++) {
        // Get rawDepth
        int offsetIn = x + y*rawWidth;
        int rawDepth = rawDepths[offsetIn];
        // New Offset if image flipped vertically
        int offset = 0;
        if(flipImage==false){offset = x + y*rawWidth;}
        if(flipImage==true){offset = y*rawWidth + rawWidth - x - 1;}
        // Set Pixel
        if (rawDepth > thresholdMin && rawDepth < thresholdMax) {
          output.pixels[offset] = color(255, 255, 255); // set to white
        } else {
          output.pixels[offset] = color(0, 0, 0);       // set to black
        }
      }
    }
    output.updatePixels();

    return output;
  }
}
