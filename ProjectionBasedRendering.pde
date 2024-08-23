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
final float Z_NEAR = (1.0f/tan(radians(FOV_DEG/2.0f))) * frustumOffset; //distance from view point to camera
final float Z_FAR = 110;
final float objectRotationSpeed = 20; //Object rotation speed (degrees/second)
final float playerRotationSpeed = 1; //Player rotation speed (degrees/second)
final float[] zeroVec = new float[] {0, 0, 0};
//final String ROOT_DIRECTORY = "data"; //relative; looks in Processing data folder

/*Game States*/
boolean CAN_MOVE = false;
boolean W_Pressed = false;
boolean A_Pressed = false;
boolean S_Pressed = false;
boolean D_Pressed = false;
//boolean Q_Pressed = false;
//boolean E_Pressed = false;
float playerOrientation = 0; //Player orientation (degrees)


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
MeshBuilder.Mesh jet, fish1, fish2, fish3, fish4, fish5, fish6, fish7, cube1, cube2;
MeshBuilder.Mesh[] activeScene, fishScene, jetScene, cubeScene;

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
  topPlane = new MeshBuilder.Plane(new float[] {0, -0.5f, Z_NEAR}, vect3normalize(new float[] {0, Z_NEAR, 0.5f}));
  bottomPlane = new MeshBuilder.Plane(new float[] {0, 0.5f, Z_NEAR}, vect3normalize(new float[] {0, -Z_NEAR, 0.5f}));
  leftPlane = new MeshBuilder.Plane(new float[] {-0.5f, 0, Z_NEAR}, vect3normalize(new float[] {Z_NEAR, 0, 0.5f}));
  rightPlane = new MeshBuilder.Plane(new float[] {0.5f, 0, Z_NEAR}, vect3normalize(new float[] {-Z_NEAR, 0, 0.5f}));
  FRUSTUM = new MeshBuilder.Plane[] {frontPlane, backPlane, topPlane, bottomPlane, leftPlane, rightPlane};

  //load shapePoint(s) data
  cube1 = new MeshBuilder.Mesh(cubePoints, cubeFaces);
  cube2 = new MeshBuilder.Mesh(cube1);

  //load in 3D model data
  try {
    println("reading STL/OBJs...");
    jet = MeshBuilder.parseSTL(sketchPath("data/jet.stl"));
    fish1 = MeshBuilder.parseOBJ(sketchPath("data/Goldfish.obj"));
    fish2 = MeshBuilder.parseOBJ(sketchPath("data/fish.obj"));
    fish3 = MeshBuilder.parseOBJ(sketchPath("data/Mackerelfish.obj"));
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
  //fish4
  MeshBuilder.applyTransformations(fish4, new float[] {0, -30, 8}, 0, 0, 180);
  //fish5
  MeshBuilder.applyTransformations(fish5, new float[] {50, -50, 8}, 0, 0, 180);
  //fish6
  MeshBuilder.applyTransformations(fish6, new float[] {-50, 50, 8}, 0, 0, 180);
  //fish7
  MeshBuilder.applyTransformations(fish7, new float[] {20, 50, 8}, 0, 0, 180);

  //initialize scences, lists of meshes, to be rendered
  fishScene = new MeshBuilder.Mesh[] {fish1, fish2, fish3, fish4, fish5, fish6, fish7, cube1};
  jetScene = new MeshBuilder.Mesh[] {jet};
  cubeScene = new MeshBuilder.Mesh[] {cube2};
  
  activeScene = cubeScene;
}
float[] top, bottom, left, right;
void draw() {
  background(#D3D3D3);//reset canvas to prepare for upcoming frame
  text("FPS: " + nf(frameRate, 0, 2), width - 10, height - 10);//display FPS text overlay
  if (frustumCulling) {
    text("Frustum Clipping: ON", width - 10, 30);
  } else {
    text("Frustum Clipping: OFF", width - 10, 30);
  }
  if (backfaceCulling) {
    text("Backface Clipping: ON", width - 10, 60);
  } else {
    text("Backface Clipping: OFF", width - 10, 60);
  }

  /*Benchmarking Disabled for itch.IO upload
   if (benchmarking) {
   totalFrameRate += frameRate;
   frameCounter++;
   
   if (frameCounter == framesToTest) {
   float avgFrameRate = totalFrameRate / framesToTest;
   println("Average Frame Rate: " + avgFrameRate);
   noLoop(); // Stop the sketch after benchmarking
   }
   }
   */

  for (MeshBuilder.Mesh mesh : activeScene) {
    float rotationIncrement = objectRotationSpeed / frameRate; //make rotation frame-rate independent
    playerOrientation = 0;
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
          if (CAN_MOVE) {
            if (keyCode == UP || W_Pressed) { //view forward
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Z_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == DOWN || S_Pressed) { //view back
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Z_PLUS, MOVEMENT_SPEED));
            }
            if (keyCode == RIGHT || D_Pressed) { //view right
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(X_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == LEFT || A_Pressed) { //view left
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(X_PLUS, MOVEMENT_SPEED));
            }
            if (keyCode == CONTROL) { //view down
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_MINUS, MOVEMENT_SPEED));
            }
            if (keyCode == SHIFT) { // view up
              transformedPoint = apply3DTranslation(transformedPoint, vectConstMul(Y_PLUS, MOVEMENT_SPEED));
            }
            //if (Q_Pressed) { //view rotate left
            //  transformedPoint = apply3DRotationY(transformedPoint, zeroVec, playerRotationSpeed);
            //  playerOrientation -= 1;
            //}
            //if (E_Pressed) { //view rotate right
            //  transformedPoint = apply3DRotationY(transformedPoint, zeroVec, -playerRotationSpeed);
            //  playerOrientation += 1;
            //}
          }
          uniquePoints.put(pointKey, transformedPoint);
        }
      }
      face.normal = apply3DRotationY(face.normal, zeroVec, rotationIncrement);
      //face.normal = apply3DRotationX(face.normal, new float[]{0, 0, 0}, rotationIncrement/2);
      // Apply player's view rotation on the entire mesh (or camera)
      //if (Q_Pressed || E_Pressed) {
      //  face.normal = apply3DRotationY(face.normal, zeroVec, playerOrientation);
      //}
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
  /*Movement*/
  //if (!benchmarking) { //disabled for itch.io upload
  if (key == 'w') {
    W_Pressed = true;
  }
  if (key == 'a') {
    A_Pressed = true;
  }
  if (key == 's') {
    S_Pressed = true;
  }
  if (key == 'd') {
    D_Pressed = true;
  }
  //if (key == 'q') {
  //  Q_Pressed = true;
  //}
  //if (key == 'e') {
  //  E_Pressed = true;
  //}
  
  /*Toggling*/
  if (key == 'f') { //toggle frustum culling
    benchmarking = true;
    frustumCulling = !frustumCulling;
  } else if (key == 'b') { //toggle backface culling
    benchmarking = true;
    backfaceCulling = !backfaceCulling;
  } else if (key == 'o') { //(does nothing for itch.io upload) begin benchmark (optimized)
    benchmarking = true;
  } else if (key == 'o') { //toggle optimizations (used to be the disable optimizations key == 'u' function, but change for itch.io upload)
    benchmarking = true;
    frustumCulling = !frustumCulling;
    backfaceCulling = !backfaceCulling;
  }
  
  /*Scene Toggling*/
  if (key == '1'){
    activeScene = cubeScene;
  }
  else if (key == '2'){
    activeScene = fishScene;
  }
  else if (key == '3'){
    activeScene = jetScene;
  }
  //}
}

void keyReleased() {
  CAN_MOVE = false;
  W_Pressed = false;
  A_Pressed = false;
  S_Pressed = false;
  D_Pressed = false;
  //Q_Pressed = false;
  //E_Pressed = false;
}
