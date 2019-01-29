/**
 * Helper class to detect blobs within an input image.
 *   * takes an input image
 *   * determines where the blobs are
 *   * ignores any blobs that are small (below the passed threshold)
 *   * can calculate a collection of punktiert BAttraction objects
 */
class Detector {
  BlobDetection blobDetection;
  PImage scaledImage;
  ArrayList<Blob> blobs;
  int pointCountThreshold;

  public Detector(int scaledWidth, int scaledHeight, int pointCountThreshold) {
    this.blobDetection = new BlobDetection(scaledWidth, scaledHeight);
    this.blobDetection.setThreshold(0.2);

    this.scaledImage = new PImage(scaledWidth, scaledHeight, RGB);
    this.blobs = new ArrayList<Blob>();
    this.pointCountThreshold = pointCountThreshold;
  }

  /**
   * Detects the blobs in the passed image. The previous contents of the blobs
   * instance variable will be discarded and replaced with the new set based on
   * the new input image
   */
  public void detectBlobs(PImage image) {
    // scaling the image down helps the performance of the blob detection
    scaledImage.copy(image, 0, 0, image.width, image.height, 0, 0, scaledImage.width, scaledImage.height);

    // blurring results in a smoother blob definition, but is also slower
    if (useBlur) {
      scaledImage.filter(BLUR);
    }

    // call out to the blob detection library to find the blobs
    blobDetection.computeBlobs(scaledImage.pixels);

    // iterate over the blobs keeping the ones that satisfy our point threshold
    blobs = new ArrayList<Blob>();
    for (int i = 0; i < blobDetection.getBlobNb(); i++) {
      Blob blob = blobDetection.getBlob(i);
      if (blob.getEdgeNb() >= pointCountThreshold) {
        blobs.add(blob);
      }
    }
  }

  /**
   * Draw the current set of blobs
   */
  public void drawBlobs(color c) {
    noFill();
    for (Blob b : blobs) {
        strokeWeight(1);
        stroke(c);
        for (int i = 0; i < b.getEdgeNb(); i++) {
          EdgeVertex eA = b.getEdgeVertexA(i);
          EdgeVertex eB = b.getEdgeVertexB(i);
          if (eA !=null && eB !=null) {
            // D(x,y) = [0,1] !
            // line(eA.x*width, eA.y*height, eB.x*width, eB.y*height);
            // line(eA.x*width*zoomKinect+cameraOffsetX, eA.y*height*zoomKinect+cameraOffsetY, eB.x*width*zoomKinect+cameraOffsetX, eB.y*height*zoomKinect+cameraOffsetY);
            line(eA.x*(xMax-xMin)+xMin, eA.y*(yMax-yMin)+yMin, eB.x*(xMax-xMin)+xMin, eB.y*(yMax-yMin)+yMin);
          }
        }
    }
    rect(xMin, yMin, xMax-xMin, yMax-yMin);
  }

  /**
   * Create a set of punktiert BAttraction objects based on the current
   * set of blobs
   */
  public BAttraction[] makePunktiertAttractions() {
    ArrayList<BAttraction> attractions = new ArrayList<BAttraction>();

    for (Blob blob : blobs) {
      Vec position = getBlobCentre(blob);
      float radius = getBlobRadius(blob);
      float strength = getBlobStrength(blob);
      attractions.add(new BAttraction(position, radius, strength));
    }
    return attractions.toArray(new BAttraction[attractions.size()]);
  }

  /** Calculates the centre of the blob */
  private Vec getBlobCentre(Blob blob) {
    // simply using centre of bounding rectangle.
    float midX = blob.xMin + ((blob.xMax-blob.xMin) / 2.0);
    float midY = blob.yMin + ((blob.yMax-blob.yMin) / 2.0);
    // return new Vec(midX*width, midY*height);
    // return new Vec(midX*width*zoomKinect+cameraOffsetX, midY*height*zoomKinect+cameraOffsetY);
    return new Vec(midX*(xMax-xMin)+xMin, midY*(yMax-yMin)+yMin);
  }

  /** Calculates the radius of the blob */
  private float getBlobRadius(Blob blob) {
    // calculate bounding rectangle, and then use the average of the two dimensions as the radius
    float w = (blob.xMax-blob.xMin)*width;
    float h = (blob.yMax-blob.yMin)*height;
    // return (w + h) / 4.0;
    return (w + h) / 5.0; // -- attractor légèrement plus petit que le blob, pour diminuer l'effet de cercle du blob (feuilles en cercle autour)
  }

  /** Calculates the strength of the blob */
  private float getBlobStrength(Blob blob) {
    // return random(1, 120) / -10.0;
    return -6.0;

  }
}
