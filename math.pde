float[][] matMul(float[][] M1, float[][] M2) {
    int numRowsM1 = M1.length;
    int numColsM1 = M1[0].length;
    int numRowsM2 = M2.length;
    int numColsM2 = M2[0].length;

    if (numColsM1 != numRowsM2) {
        System.out.println("Matrix multiplication dimension mismatch");
        return null;
    }

    // Initialize the output matrix with appropriate dimensions
    float[][] output = new float[numRowsM1][numColsM2];

    // Perform the matrix multiplication
    for (int i = 0; i < numRowsM1; i++) {
        for (int j = 0; j < numColsM2; j++) {
            float entry = 0;
            //compute the dot-product of corresponding row and column vectors
            for (int k = 0; k < numColsM1; k++) {
                entry += M1[i][k] * M2[k][j];
            }
            output[i][j] = entry;
        }
    }
    return output;
}

float[] apply3DTranslation(float[] v, float[] v_translate) {
  return new float[] {v[0] + v_translate[0], v[1] + v_translate[1], v[2] + v_translate[2]};
}

float[] apply3DRotationX(float[] v, float[] centroid, float degrees) {
  float theta = radians(degrees);

  // Translate the point to the origin based on the centroid
  float x = v[0] - centroid[0];
  float y = v[1] - centroid[1];
  float z = v[2] - centroid[2];
  
  // Apply the rotation (R_x(theta))
  float a = x;
  float b = cos(theta) * y - sin(theta) * z;
  float c = sin(theta) * y + cos(theta) * z;
  
  //Translate the point back to its original position
  return new float[] {a + centroid[0], b + centroid[1], c + centroid[2]};
}

float[] apply3DRotationY(float[] v, float[] centroid, float degrees) {
  float theta = radians(degrees);

  // Translate the point to the origin based on the centroid
  float x = v[0] - centroid[0];
  float y = v[1] - centroid[1];
  float z = v[2] - centroid[2];
  
  // Apply the rotation (R_y(theta))
  float a = cos(theta) * x + sin(theta) * z;
  float b = y;
  float c = -sin(theta) * x + cos(theta) * z;
  
  //Translate the point back to its original position
  return new float[] {a + centroid[0], b + centroid[1], c + centroid[2]};
}

float[] apply3DRotationZ(float[] v, float[] centroid, float degrees){
  float theta = radians(degrees);

  // Translate the point to the origin based on the centroid
  float x = v[0] - centroid[0];
  float y = v[1] - centroid[1];
  float z = v[2] - centroid[2];

  // Apply the rotation (R_z(theta))
  float a = cos(theta) * x - sin(theta) * y;
  float b = sin(theta) * x + cos(theta) * y;
  float c = z;

  // Translate the point back to its original position
  return new float[] {a + centroid[0], b + centroid[1], c + centroid[2]};
}

/*Function to calculate the centroid of the shape*/
static float[] calculateCentroid(float[][] points) {
  float sumX = 0, sumY = 0, sumZ = 0;
  int numPoints = points.length;

  for (int i = 0; i < numPoints; i++) {
    sumX += points[i][0];
    sumY += points[i][1];
    sumZ += points[i][2];
  }

  return new float[] {sumX / numPoints, sumY / numPoints, sumZ / numPoints};
}

/*Function to project 3D coordinates to 2D display*/
float[] proj2DTo3D(float[] P) {
  float X = P[0];
  float Y = P[1];
  float Z = P[2];
  float fovConst = tan(FOV/2)*Z;
  return new float[] {width*X/fovConst, height*Y/fovConst};
}
