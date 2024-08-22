/*Benchmarking variables*/
boolean frustumCulling = true;
boolean backfaceCulling = true;
// ---
int framesToTest = 300; // Number of frames to average
int frameCounter = 0;
float totalFrameRate = 0;
boolean benchmarking = false;

/*Constants*/
final float FOV_DEG = 45.0f; //Field of view (degrees)
final float FOV_RAD = radians(FOV_DEG); //Field of view (radians)
final float MOVEMENT_SPEED = 0.5f;
final float frustumOffset = 1.0f;
final float Z_NEAR = (1.0f/tan(radians(FOV_DEG/2.0f))) * frustumOffset;
final float Z_FAR = 110;
boolean CAN_MOVE = false;
float objectRotationAngle = 0; //Current rotation angle
float objectRotationSpeed = 20; //Rotation speed (degrees/second)
final static String ROOT_DIRECTORY = "\\Users\\joelc\\OneDrive\\Documents\\Processing\\Projection_Based_Rendering\\ProjectionBasedRendering\\data\\";

/*Plane objects*/
MeshBuilder.Plane frontPlane, backPlane, topPlane, bottomPlane, leftPlane, rightPlane;
MeshBuilder.Plane[] FRUSTUM;

/*axis-aligned unit vectors*/
float[] Z_MINUS = new float[] {0, 0, -1};
float[] Z_PLUS = new float[] {0, 0, 1};
float[] Y_MINUS = new float[] {0, -1, 0};
float[] Y_PLUS = new float[] {0, 1, 0};
float[] X_MINUS = new float[] {-1, 0, 0};
float[] X_PLUS = new float[] {1, 0, 0};

/*Mesh objects*/
MeshBuilder.Mesh jet, fish1, fish2, fish3, fish4, fish5, fish6, fish7, cube;
MeshBuilder.Mesh[] meshes;

void setup() {
  //set display window dimensions
  size(1280, 720);
  
  //top = proj2DTo3D(new float[] {0, -0.5f, Z_NEAR});
  //bottom = proj2DTo3D(new float[] {0, 0.5f, Z_NEAR});
  //left = proj2DTo3D(new float[] {-0.5f, 0, Z_NEAR});
  //right = proj2DTo3D(new float[] {0.5f, 0, Z_NEAR});
  //println(Arrays.toString(top));
  //println(Arrays.toString(bottom));
  //println(Arrays.toString(left));
  //println(Arrays.toString(right));

  //set text-overlay color, alignment, and size
  fill(0);
  textSize(24);
  textAlign(RIGHT);

  //load frustum planes
  frontPlane = new MeshBuilder.Plane(new float[] {0, 0, Z_NEAR}, Z_PLUS);
  backPlane = new MeshBuilder.Plane(new float[] {0, 0, Z_FAR}, Z_MINUS);
  topPlane = new MeshBuilder.Plane(new float[] {0, -0.5f, Z_NEAR}, vect3normalize(new float[] {0, Z_NEAR, 0.5f}));
  bottomPlane = new MeshBuilder.Plane(new float[] {0, 0.5f, Z_NEAR}, vect3normalize(new float[] {0, -Z_NEAR, 0.5f}));
  leftPlane = new MeshBuilder.Plane(new float[] {-0.5f, 0, Z_NEAR}, vect3normalize(new float[] {Z_NEAR, 0, 0.5f}));
  rightPlane = new MeshBuilder.Plane(new float[] {0.5f, 0, Z_NEAR}, vect3normalize(new float[] {-Z_NEAR, 0, 0.5f}));
  FRUSTUM = new MeshBuilder.Plane[] {frontPlane, backPlane, topPlane, bottomPlane, leftPlane, rightPlane};

  //load shapePoint(s) data
  cube = new MeshBuilder.Mesh(cubePoints, cubeFaces);

  //load in 3D model data
  try {
    println("reading STL/OBJs...");
    jet = MeshBuilder.parseSTL("jet.stl");
    fish1 = MeshBuilder.parseOBJ("Goldfish.obj");
    fish2 = MeshBuilder.parseOBJ("fish.obj");//new MeshBuilder.Mesh(fish1);
    fish3 = MeshBuilder.parseOBJ("Mackerelfish.obj");
    fish4 = new MeshBuilder.Mesh(fish1);
    fish5 = new MeshBuilder.Mesh(fish2);
    fish6 = new MeshBuilder.Mesh(fish3);
    fish7 = new MeshBuilder.Mesh(fish2);
  }
  catch (IOException e) {
    e.printStackTrace();
    println("failed to load STL.");
  }
  println("3D model(s) loaded succesfully!");

  //move meshes to start position/orientations/scale
  /*jet*/
  MeshBuilder.applyTransformations(jet, new float[] {0, -30, 100}, 90, 0, 0); //jet

  /*fishes*/
  //fish 1
  MeshBuilder.applyTransformations(fish1, new float[] {12, 0, 100}, 0, 0, 180);
  //fish2
  MeshBuilder.applyTransformations(fish2, new float[] {-2, 0, 15}, 0, 0, 180);
  MeshBuilder.applyScaling(fish2, 5, 5, 5);
  //fish3
  MeshBuilder.applyTransformations(fish3, new float[] {0, 10, 100}, 0, 0, 180);

  //initialize list of meshes to be rendered
  meshes = new MeshBuilder.Mesh[] {fish1, fish2, fish3, fish4, fish5, fish6, fish7, cube}; //{jet};//cubePoints
}
float[] top, bottom, left, right;
void draw() {
  background(#D3D3D3);//reset canvas to prepare for upcoming frame
  text("FPS: " + nf(frameRate, 0, 2), width - 10, height - 10);//display FPS text overlay
  //line(top[0], top[1], right[0], right[1]);
  //line(right[0], right[1], bottom[0], bottom[1]);
  //line(bottom[0], bottom[1], left[0], left[1]);
  //line(left[0], left[1], top[0], top[1]);

  if (benchmarking) {
    totalFrameRate += frameRate;
    frameCounter++;

    if (frameCounter == framesToTest) {
      float avgFrameRate = totalFrameRate / framesToTest;
      println("Average Frame Rate: " + avgFrameRate);
      noLoop(); // Stop the sketch after benchmarking
    }
  }

  for (MeshBuilder.Mesh mesh : meshes) {
    float rotationIncrement = objectRotationSpeed / frameRate; //make rotation frame-rate independent
    // Map to store unique points and their transformations
    Map<String, float[]> uniquePoints = new HashMap<>();
    // First pass: collect unique points
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.size(); i++) {
        float[] point = face.points.get(i);
        String pointKey = point[0] + "," + point[1] + "," + point[2];

        // If the point has not been transformed yet, do so
        if (!uniquePoints.containsKey(pointKey)) {
          //float[] transoformationVec = new float[] {0, 0, 0};
          float[] transformedPoint = apply3DRotationY(point, mesh.centroid, rotationIncrement);//point;
          //transformedPoint = apply3DRotationX(transformedPoint, mesh.centroid, rotationIncrement/2);
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
            if (keyCode == CONTROL) {
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == SHIFT) { // spacebar?
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_PLUS, MOVEMENT_SPEED));
            }
          }
          uniquePoints.put(pointKey, transformedPoint);
        }
      }
      face.normal = apply3DRotationY(face.normal, new float[]{0, 0, 0}, rotationIncrement); // Rotation applied, no translation
      //face.normal = apply3DRotationX(face.normal, new float[]{0, 0, 0}, rotationIncrement/2);
    }

    //Second pass: update the faces with the transformed points
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
  if (!benchmarking) {
    if (key == 'f') {
      benchmarking = true;
      frustumCulling = !frustumCulling;
    } else if (key == 'b') {
      benchmarking = true;
      backfaceCulling = !backfaceCulling;
    }else if (key == 'o') {
      benchmarking = true;
    }else if (key == 'u') {
      benchmarking = true;
      frustumCulling = !frustumCulling;
      backfaceCulling = !backfaceCulling;
    }
  }
}

void keyReleased() {
  CAN_MOVE = false;
}
