import java.io.*;
import java.util.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public static class MeshBuilder {

  // Custom class to hold the points, edges, and centroid
  public static class Mesh {
    //public float[][] points;
    public Face[] faces;
    public float[] centroid;

    public Mesh(Face[] faces) {
      //this.points = points;
      this.faces = faces;
      this.centroid = calculateCentroid(faces);
    }
    public Mesh(float[][] points, int[][] faces) {
      //this.points = points;
      List<Face> faceList = new ArrayList<>();
      for(int[] face : faces) {
        List<float[]> facePoints = new ArrayList<>();
        for(int point : face) {
          facePoints.add(points[point]);
        }
        faceList.add(new Face(facePoints.toArray(new float[0][0])));
      }
      this.faces = faceList.toArray(new Face[0]);
      this.centroid = calculateCentroid(this.faces);
    }
  }

  public static class Face {
    public float[][] points;
    public float[] normal;
    
    public Face(float[][] points, float[] normal) {
      this.points = points;
      this.normal = normal;
    }
    public Face(float[][] points) {
      this.points = points;
      this.normal = calculateNorm(points);
    }
  }
  
  public static class Plane extends Face  {
    public float D;//plane constant: dot(normal, P_0)
    
    public Plane (float[][] points, float[] normal)  {
      super(points, normal); // Call the Face constructor
      this.D = -dotProd(normal, points[0]);
    }
  }

  // Method to parse the STL file and return an Mesh object
  public static Mesh parseSTL(String filename) throws IOException {
    FileInputStream fileInputStream = new FileInputStream(new File(filename));
    byte[] header = new byte[80]; // 80-byte header
    fileInputStream.read(header); // Read the header
    byte[] countBytes = new byte[4];
    fileInputStream.read(countBytes);
    int triangleCount = ByteBuffer.wrap(countBytes).order(ByteOrder.LITTLE_ENDIAN).getInt();

    //List<float[]> verticesList = new ArrayList<>();
    //Map<float[], Integer> vertexIndexMap = new HashMap<>();
    List<Face> faceList = new ArrayList<>();

    for (int i = 0; i < triangleCount; i++) {
      fileInputStream.skip(12); //skip normal vector
      // Read the normal vector
      //byte[] normalBytes = new byte[12];
      //fileInputStream.read(normalBytes);
      //float nx = ByteBuffer.wrap(normalBytes, 0, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
      //float ny = ByteBuffer.wrap(normalBytes, 4, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
      //float nz = ByteBuffer.wrap(normalBytes, 8, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
      //float[] normal = new float[]{nx, ny, nz};
      //normals.add(normal);  // Save the normal vector

      float[][] triangle = new float[3][];
      for (int v = 0; v < 3; v++) {
        byte[] vertexBytes = new byte[12];
        fileInputStream.read(vertexBytes);
        float x = ByteBuffer.wrap(vertexBytes, 0, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float y = ByteBuffer.wrap(vertexBytes, 4, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float z = ByteBuffer.wrap(vertexBytes, 8, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        triangle[v] = new float[]{x, y, z};

        // Check if vertex is already in the list
        //if (!vertexIndexMap.containsKey(triangle[v])) {
        //  verticesList.add(triangle[v]);
        //  vertexIndexMap.put(triangle[v], verticesList.size() - 1);
        //}
      }
      Face face = new Face(triangle, calculateNorm(triangle));
      //println(face.normal[0] + " " + face.normal[1] + " " + face.normal[2]);
      faceList.add(face);
      //triangleList.add(triangle);

      // Store edges as index pairs
      //edgesList.add(new int[]{vertexIndexMap.get(triangle[0]), vertexIndexMap.get(triangle[1])});
      //edgesList.add(new int[]{vertexIndexMap.get(triangle[1]), vertexIndexMap.get(triangle[2])});
      //edgesList.add(new int[]{vertexIndexMap.get(triangle[2]), vertexIndexMap.get(triangle[0])});

      fileInputStream.skip(2); // Skip attribute byte count
    }
    fileInputStream.close();

    // Convert the vertices list to a float[][] array
    //float[][] points = verticesList.toArray(new float[0][0]);

    // Convert the list of faces to an int[][] array
    Face[] faces = faceList.toArray(new Face[0]);

    // Return an Mesh object containing the arrays
    return new Mesh(faces);
  }
  
  public static float[] calculateCentroid(Mesh mesh){
    return calculateCentroid(mesh.faces);
  }
  
  public static float[] calculateCentroid(Face[] faces){
    float sumX = 0, sumY = 0, sumZ = 0;
    int numPoints = 0;
    
    // Use a Set to store unique points
    Set<String> uniquePoints = new HashSet<>();
    
    for (Face face : faces) {
        for (float[] point : face.points) {
            // Convert the point to a String to store in the Set (this helps with uniqueness)
            String pointKey = point[0] + "," + point[1] + "," + point[2];
            
            // If the point is not already in the Set, add it and update the sums
            if (uniquePoints.add(pointKey)) {
                sumX += point[0];
                sumY += point[1];
                sumZ += point[2];
                numPoints++;
            }
        }
    }
    
    // Calculate and return the centroid
    return new float[] {sumX / numPoints, sumY / numPoints, sumZ / numPoints};
  }
}
