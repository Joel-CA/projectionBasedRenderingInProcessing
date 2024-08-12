final float FOV = radians(45); //Field of view (degrees->radians)
final float MOVEMENT_SPEED = 0.5;
boolean CAN_MOVE = false;
float objectRotationAngle = 0; //Current rotation angle
float objectRotationSpeed = 25; //Rotation speed (degrees/second)

/*Mesh objects*/
MeshBuilder.Mesh jet, cube;
MeshBuilder.Mesh[] meshes;

/*axis-aligned unit vectors*/
float[] Z_MINUS = new float[] {0, 0, -1};
float[] Z_PLUS = new float[] {0, 0, 1};
float[] Y_MINUS = new float[] {0, -1, 0};
float[] Y_PLUS = new float[] {0, 1, 0};
float[] X_MINUS = new float[] {-1, 0, 0};
float[] X_PLUS = new float[] {1, 0, 0};

void setup() {
  //set display window dimensions
  size(1280, 720);

  //set text-overlay color, alignment, and size
  fill(0);
  textSize(24);
  textAlign(RIGHT);

  //load shapePoint(s) data
  cube = new MeshBuilder.Mesh(cubePoints, cubeFaces);

  //load in STL data
  try {
    println("reading STLs...");
    jet = MeshBuilder.parseSTL("\\Users\\joelc\\OneDrive\\Documents\\Processing\\Projection_Based_Rendering\\ProjectionBasedRendering\\data\\jet.stl");
  }
  catch (IOException e) {
    e.printStackTrace();
    println("failed to load STL.");
  }
  println("STL loaded succesfully!");

  //move jet to starter position
  float[] jetTranslation = new float[] {0, -35, 200};
  for (MeshBuilder.Face face : jet.faces) {
    for (int i = 0; i < face.points.length; i++) {
      face.points[i] = apply3DTranslation(apply3DRotationX(face.points[i], jet.centroid, 90), jetTranslation);
    }
  }
  jet.centroid = apply3DTranslation(jet.centroid, jetTranslation);

  //initialize list of meshes to be rendered
  meshes = new MeshBuilder.Mesh[] {cube}; //cubePoints
}

void draw() {
  background(#D3D3D3);//reset canvas to prepare for upcoming frame
  text("FPS: " + nf(frameRate, 0, 2), width - 10, height - 10);//display FPS text overlay

  //TODO: Wrap all "drawing" in a conditional that checks the object/points are contained within the viewing fustrum (along all axis) and not obstructed by other objects (z-buffer?)
  //idea: check if display-space pixel location is already being occupied by something with greater z-value (perhaps within threshold of distance?) before drawing, if so dont drawline
  for (MeshBuilder.Mesh mesh : meshes) {
    // Map to store unique points and their transformations
    Map<String, float[]> uniquePoints = new HashMap<>();
    float rotationIncrement = objectRotationSpeed / frameRate; //make rotation frame-rate independent
    // First pass: collect unique points
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.length; i++) {
        float[] point = face.points[i];
        String pointKey = point[0] + "," + point[1] + "," + point[2];

        // If the point has not been transformed yet, do so
        if (!uniquePoints.containsKey(pointKey)) {
          float[] transformedPoint = apply3DRotationY(point, mesh.centroid, rotationIncrement);//point;

          if (key == CODED && CAN_MOVE) {
            if (keyCode == UP) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Z_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == DOWN) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Z_PLUS, MOVEMENT_SPEED));
            }
            if (keyCode == RIGHT) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(X_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == LEFT) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(X_PLUS, MOVEMENT_SPEED));
            }
            if (keyCode == SHIFT) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == ALT) { // spacebar?
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_PLUS, MOVEMENT_SPEED));
            }
          }
          uniquePoints.put(pointKey, transformedPoint);
        }
      }
      face.normal = apply3DRotationY(face.normal, new float[]{0, 0, 0}, rotationIncrement); // Rotation applied, no translation
    }

    // Second pass: update the faces with the transformed points
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.length; i++) {
        String pointKey = face.points[i][0] + "," + face.points[i][1] + "," + face.points[i][2];
        face.points[i] = uniquePoints.get(pointKey);
      }
    }

    // Recalculate the centroid after transformation
    mesh.centroid = MeshBuilder.calculateCentroid(mesh.faces);

    // Draw the geometry
    stroke(#FA0000);
    drawGeometry(mesh.faces);
  }
}

void keyPressed() {
  CAN_MOVE = true;
}

void keyReleased() {
  CAN_MOVE = false;
}
