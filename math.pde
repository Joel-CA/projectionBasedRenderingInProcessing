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

static float[] apply3DTranslation(float[] v, float[] v_translate) {
  return new float[] {v[0] + v_translate[0], v[1] + v_translate[1], v[2] + v_translate[2]};
}

static float[] vectConstMul(float[] v, float c) {
  return new float[] {v[0]*c, v[1]*c, v[2]*c};
}

static float dotProd(float[] v1, float[] v2) {
  float prod = 0;
  if (v1.length != v2.length){
    println("Error: dot product must take in equal length vectors");
    throw null;
  }
  for (int i = 0; i < v1.length; i++){
    prod += v1[i]*v2[i];
  }
  return prod;
}

static float[] vect3CrossProd(float[] v1, float[] v2) {
  return new float[] {v1[1]*v2[2] - v2[1]*v1[2], -(v1[0]*v2[2] - v2[0]*v1[2]), v1[0]*v2[1] - v2[0]*v1[1]};
}

/*Function to normalize a vector*/
static float[] vect3normalize(float[] v) {
  float size = magnitude(v);
  return new float[] {v[0]/size, v[1]/size, v[2]/size};
}

/*Function to calculate vector magnitude*/
static float magnitude(float[] v) {
  float squared_sum = 0;
  for (int i = 0; i < v.length; i++){
    squared_sum += v[i]*v[i];
  }
  return (float) Math.pow(squared_sum, 1/2);
}

/*Function to calculate the normal vector of a plane*/
static float[] calculateNorm(List<float[]> pointsInPlane) {
  float[] point1 = pointsInPlane.get(0);
  float[] point2 = pointsInPlane.get(1);
  float[] point3 = pointsInPlane.get(2);
  
  float[] neg_point1 = vectConstMul(point1, -1);
  float[] vector1 = apply3DTranslation(point2, neg_point1);
  float[] vector2 = apply3DTranslation(point3, neg_point1);
  
  return vect3CrossProd(vector1, vector2);
}

//Function to determine if point is in front or behind a given plane
Boolean isInFrontOfPlane(float[] point, MeshBuilder.Plane plane){
  return dotProd(point, plane.normal) >= plane.D;
}

//Function to determine the point of intersection between a given line (defined by 2 points) and plane
float[] planeIntersectPoint(float[] p1, float[] p2, MeshBuilder.Plane plane) {
  float[] lineVector = apply3DTranslation(p2, vectConstMul(p1, -1));
  float numerator = plane.D - dotProd(plane.normal, p1);
  float denominator = dotProd(plane.normal, lineVector);
  float t = numerator/denominator;
  return apply3DTranslation(p1, vectConstMul(lineVector, t));
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
  float fovConst = tan(FOV_RAD/2)*Z;
  return new float[] {width*X/fovConst + width/2, height*Y/fovConst + height/2};
}
