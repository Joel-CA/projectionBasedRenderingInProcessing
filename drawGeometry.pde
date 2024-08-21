//color[] colors = {color(10, 10, 10), color(255, 21, 21), color(21, 255, 21), color(21, 21, 255)};
final float[] zeroVec = new float[] {0, 0, 0};
void drawGeometry(MeshBuilder.Face[] faces) {
  // Set to store the drawn lines
  Set<String> linesDrawn = new HashSet<>();

  for (MeshBuilder.Face face : faces) {
    if (dotProd(getOrDefault(face.points, 0, zeroVec), face.normal) < 0){//(face.normal[2] <= 0) { // Only draw faces facing the viewer
      //Start with the original face
      //List<float[]> vertices = new ArrayList<>(Arrays.asList(face.points));

      List<float[]> vertices = frustumClipPolygon(face.points);//new ArrayList<>(Arrays.asList(face.points));
      //if (vertices.size() > 0) {
      //  println("Number of vertices: " + vertices.size() + " ---------");
      //}

      for (int i = 0; i < vertices.size(); i++) {
        //Get the points of the line
        float[] P1 = vertices.get(i);
        float[] P2 = vertices.get((i+1)%vertices.size());

        //Create a key for the line by sorting the points
        String lineKey = createLineKey(P1, P2);

        //Check if this line has already been drawn
        //And if the line needs to be clipped
        if (!linesDrawn.contains(lineKey)) {
          // Project the points to 2D
          float[] p1 = proj2DTo3D(P1);
          float[] p2 = proj2DTo3D(P2);

          //Draw the line
          //stroke(colors[i%colors.length]);
          line(p1[0], p1[1], p2[0], p2[1]);

          //Add the line to the set of drawn lines
          linesDrawn.add(lineKey);
        }
      }
    }
  }
}

//Function to clip polygon against the viewing frustum
List<float[]> frustumClipPolygon(List<float[]> polygonPoints) {
  //Clip the face against each plane in the frustum
  List<float[]> outputList = polygonPoints;
  for (MeshBuilder.Plane frustrumPlane : FRUSTUM) {
    List<float[]> inputList = new ArrayList<>(outputList);
    outputList.clear();

    for (int i = 0; i < inputList.size(); i++) {
      float[] currentVertex = inputList.get(i);
      float[] previousVertex = inputList.get((i + inputList.size() - 1) % inputList.size());
      //float[] previousVertex = inputList.get((i - 1) % inputList.size()); //I've been told negative modular arithmetic causes unwanted behavior (sometimes?)

      boolean currentInside = isInFrontOfPlane(currentVertex, frustrumPlane);
      boolean previousInside = isInFrontOfPlane(previousVertex, frustrumPlane);
      
      //println("Current Vertex: " + Arrays.toString(currentVertex));
      //println("Previous Vertex: " + Arrays.toString(previousVertex));
      //println("Current Inside: " + currentInside);
      //println("Previous Inside: " + previousInside);

      //float[] intersectPoint = planeIntersectPoint(previousVertex, currentVertex, frustrumPlane);

      if (currentInside && previousInside) {
        outputList.add(currentVertex); // Both inside, add current vertex
      } else if (previousInside && !currentInside) {
        outputList.add(planeIntersectPoint(previousVertex, currentVertex, frustrumPlane)); // Crossing to outside
        //println("CLIP: " + Arrays.toString(currentVertex));
      } else if (!previousInside && currentInside) {
        outputList.add(planeIntersectPoint(previousVertex, currentVertex, frustrumPlane)); // Crossing to inside
        outputList.add(currentVertex); // Add current vertex as well
        //println("CLIP: " + Arrays.toString(previousVertex));
      }
      // If both vertices are outside, do nothing (clip away the edge)
    }
    if (outputList.isEmpty()) break; //if polygon is entirely outside of the frustum, stop clipping
  }
  return outputList;
}

//Helper function to create a unique key for a line (unordered pair of points)
String createLineKey(float[] P1, float[] P2) {
  // Sort points to ensure the same key for (P1, P2) and (P2, P1)
  if (comparePoints(P1, P2) > 0) {
    float[] temp = P1;
    P1 = P2;
    P2 = temp;
  }
  return Arrays.toString(P1) + "-" + Arrays.toString(P2);
}

// Helper function to compare two points lexicographically
int comparePoints(float[] P1, float[] P2) {
  for (int i = 0; i < P1.length; i++) {
    if (P1[i] != P2[i]) {
      return Float.compare(P1[i], P2[i]);
    }
  }
  return 0;
}

/*Depricated*/
//void drawCube(float[] P1, float[] P2, float[] P3, float[] P4,
//  float[] P5, float[] P6, float[] P7, float[] P8) {
//  float[] p1 = proj2DTo3D(P1);
//  float[] p2 = proj2DTo3D(P2);
//  float[] p3 = proj2DTo3D(P3);
//  float[] p4 = proj2DTo3D(P4);
//  float[] p5 = proj2DTo3D(P5);
//  float[] p6 = proj2DTo3D(P6);
//  float[] p7 = proj2DTo3D(P7);
//  float[] p8 = proj2DTo3D(P8);

//  //line(x1, y1, x2, y2)
//  stroke(#FF0D0D);
//  stroke(#229004);
//  stroke(#0D1AFF);
//  line(p1[0], p1[1], p2[0], p2[1]);
//  stroke(#229004);
//  line(p2[0], p2[1], p3[0], p3[1]);
//  stroke(#0D1AFF);
//  line(p3[0], p3[1], p4[0], p4[1]);
//  stroke(#1F1F1F);
//  line(p4[0], p4[1], p1[0], p1[1]);
//  stroke(#FF0D0D);
//  line(p5[0], p5[1], p6[0], p6[1]);
//  stroke(#229004);
//  line(p6[0], p6[1], p7[0], p7[1]);
//  stroke(#0D1AFF);
//  line(p7[0], p7[1], p8[0], p8[1]);
//  stroke(#1F1F1F);
//  line(p8[0], p8[1], p4[0], p4[1]);

//  stroke(#1F1F1F);
//  line(p2[0], p2[1], p6[0], p6[1]);
//  line(p3[0], p3[1], p7[0], p7[1]);
//  line(p1[0], p1[1], p5[0], p5[1]);
//  line(p8[0], p8[1], p5[0], p5[1]);
//}

//void drawSquare(float[] P1, float[] P2, float[] P3, float[] P4) {
//  float[] p1 = proj2DTo3D(P1);
//  float[] p2 = proj2DTo3D(P2);
//  float[] p3 = proj2DTo3D(P3);
//  float[] p4 = proj2DTo3D(P4);

//  //line(x1, y1, x2, y2)
//  stroke(#FF0D0D);
//  line(p1[0], p1[1], p2[0], p2[1]);
//  stroke(#229004);
//  line(p2[0], p2[1], p3[0], p3[1]);
//  stroke(#0D1AFF);
//  line(p3[0], p3[1], p4[0], p4[1]);
//  stroke(#1F1F1F);
//  line(p4[0], p4[1], p1[0], p1[1]);
//}

//void drawTriangle(float[] P1, float[] P2, float[] P3) {
//  float[] p1 = proj2DTo3D(P1);
//  float[] p2 = proj2DTo3D(P2);
//  float[] p3 = proj2DTo3D(P3);

//  //line(x1, y1, x2, y2)
//  stroke(#FF0D0D);
//  line(p1[0], p1[1], p2[0], p2[1]);
//  stroke(#229004);
//  line(p2[0], p2[1], p3[0], p3[1]);
//  stroke(#0D1AFF);
//  line(p3[0], p3[1], p1[0], p1[1]);
//}
