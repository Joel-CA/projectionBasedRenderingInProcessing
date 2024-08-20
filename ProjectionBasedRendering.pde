final float FOV_DEG = 45; //Field of view (degrees)
final float FOV_RAD = radians(FOV_DEG); //Field of view (radians)
final float MOVEMENT_SPEED = 0.5;
boolean CAN_MOVE = false;
float objectRotationAngle = 0; //Current rotation angle
float objectRotationSpeed = 20; //Rotation speed (degrees/second)

/*Mesh objects*/
MeshBuilder.Mesh jet, cube;
MeshBuilder.Mesh[] meshes;

/*Plane objects*/
MeshBuilder.Plane frontPlane, backPlane, topPlane, bottomPlane, leftPlane, rightPlane;
MeshBuilder.Plane[] FRUSTUM;

/*axis-aligned unit vectors*/
float frustumOffset = 1;
float Z_NEAR = 1/tan(radians(FOV_DEG/2)) * frustumOffset;
float Z_FAR = 125;
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

  //load frustum planes
  frontPlane = new MeshBuilder.Plane(new float[] {0, 0, Z_NEAR}, Z_PLUS);
  backPlane = new MeshBuilder.Plane(new float[] {0, 0, Z_FAR}, Z_MINUS);
  topPlane = new MeshBuilder.Plane(new float[] {0, -1/2, Z_NEAR}, new float[] {0, -sin(radians(FOV_DEG/2-90)), cos(radians(FOV_DEG/2))});
  bottomPlane = new MeshBuilder.Plane(new float[] {0, 1/2, Z_NEAR}, new float[] {0, sin(radians(FOV_DEG/2-90)), cos(radians(FOV_DEG/2))});
  leftPlane = new MeshBuilder.Plane(new float[] {-1/2, 0, Z_NEAR}, new float[] {-sin(radians(FOV_DEG/2-90)), 0, cos(radians(FOV_DEG/2))});
  rightPlane = new MeshBuilder.Plane(new float[] {1/2, 0, Z_NEAR}, new float[] {sin(radians(FOV_DEG/2-90)), 0, cos(radians(FOV_DEG/2))});
  FRUSTUM = new MeshBuilder.Plane[] {frontPlane, backPlane, topPlane, bottomPlane, leftPlane, rightPlane};

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
  float[] jetTranslation = new float[] {0, -30, 100};
  for (MeshBuilder.Face face : jet.faces) {
    for (int i = 0; i < face.points.size(); i++) {
      face.points.set(i, apply3DTranslation(apply3DRotationX(face.points.get(i), jet.centroid, 90), jetTranslation));
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
      for (int i = 0; i < face.points.size(); i++) {
        float[] point = face.points.get(i);
        String pointKey = point[0] + "," + point[1] + "," + point[2];

        // If the point has not been transformed yet, do so
        if (!uniquePoints.containsKey(pointKey)) {
          float[] transformedPoint = apply3DRotationY(point, mesh.centroid, rotationIncrement);//point;
          transformedPoint = apply3DRotationX(transformedPoint, mesh.centroid, rotationIncrement/2);
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
      face.normal = apply3DRotationX(face.normal, new float[]{0, 0, 0}, rotationIncrement/2);
    }

    // Second pass: update the faces with the transformed points
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.size(); i++) {
        float[] point = face.points.get(i);
        String pointKey = point[0] + "," + point[1] + "," + point[2];
        face.points.set(i, uniquePoints.get(pointKey));
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
