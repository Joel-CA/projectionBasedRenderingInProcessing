final float FOV = radians(45); //Field of view (degrees->radians)
boolean CAN_MOVE = false;

/*Mesh objects*/
MeshBuilder.Mesh jet, cube;
MeshBuilder.Mesh[] meshes;

/*axis-aligned unite vectors*/
float[] Z_MINUS = new float[] {0, 0, -1};
float[] Z_PLUS = new float[] {0, 0, 1};
float[] Y_MINUS = new float[] {0, -1, 0};
float[] Y_PLUS = new float[] {0, 1, 0};
float[] X_MINUS = new float[] {-1, 0, 0};
float[] X_PLUS = new float[] {1, 0, 0};

void setup() {
  //set display window dimensions
  size(1280, 720);
  z_buffer = new float[width][height];
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      z_buffer[i][j] = Float.POSITIVE_INFINITY;
    }
  }
  //set text-overlay color, alignment, and size
  fill(0);
  textSize(24);
  textAlign(RIGHT);

  //load shapePoint(s) data
  cube = new MeshBuilder.Mesh(cubePoints, cubeEdges, calculateCentroid(cubePoints));

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
  float[] jetTranslation = new float[] {40, 0, 200};
  for (int i = 0; i < jet.points.length; i++) {
    jet.points[i] = apply3DTranslation(apply3DRotationX(jet.points[i], jet.centroid, 90), jetTranslation);
  }
  jet.centroid = apply3DTranslation(jet.centroid, jetTranslation);

  //initialize list of meshes to be rendered
  meshes = new MeshBuilder.Mesh[] {jet}; //cubePoints
}

void draw() {
  background(#D3D3D3);//reset canvas to prepare for upcoming frame
  text("FPS: " + nf(frameRate, 0, 2), width - 10, height - 10);//display FPS text overlay

  //TODO: Wrap all "drawing" in a conditional that checks the object/points are contained within the viewing fustrum (along all axis) and not obstructed by other objects (z-buffer?)
  //idea: check if display-space pixel location is already being occupied by something with greater z-value (perhaps within threshold of distance?) before drawing, if so dont drawline

  for (MeshBuilder.Mesh mesh : meshes) {
    for (int i = 0; i < mesh.points.length; i++) {
      //mesh.points[i] = apply3DRotationY(mesh.points[i], mesh.centroid, 1);
      if (key == CODED && CAN_MOVE) {
        if (keyCode == UP) {
          mesh.points[i] = apply3DTranslation(mesh.points[i], Z_MINUS);
        }
        if (keyCode == DOWN) {
          mesh.points[i] = apply3DTranslation(mesh.points[i], Z_PLUS);
        }
        if (keyCode == RIGHT) {
          mesh.points[i] = apply3DTranslation(mesh.points[i], X_MINUS);
        }
        if (keyCode == LEFT) {
          mesh.points[i] = apply3DTranslation(mesh.points[i], X_PLUS);
        }
        if (keyCode == SHIFT) {
          mesh.points[i] = apply3DTranslation(mesh.points[i], Y_MINUS);
        }
        if (keyCode == ALT) { //spacebar?
          mesh.points[i] = apply3DTranslation(mesh.points[i], Y_PLUS);
        }
      }
    }
    stroke(#FA0000);
    drawGeometry(mesh.points, mesh.edges);
  }
}

void keyPressed() {
  CAN_MOVE = true;
}

void keyReleased() {
  CAN_MOVE = false;
}
