import java.io.*;
import java.util.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public static class MeshBuilder {

  // Custom class to hold the points, edges, and centroid
  public static class Mesh {
    public float[][] points;
    public int[][] edges;
    public float[] centroid;

    public Mesh(float[][] points, int[][] edges, float[] centroid) {
      this.points = points;
      this.edges = edges;
      this.centroid = centroid;
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

    List<float[]> verticesList = new ArrayList<>();
    Map<float[], Integer> vertexIndexMap = new HashMap<>();
    List<int[]> edgesList = new ArrayList<>();

    for (int i = 0; i < triangleCount; i++) {
      fileInputStream.skip(12); // Skip normal vector
      float[][] triangle = new float[3][];
      for (int v = 0; v < 3; v++) {
        byte[] vertexBytes = new byte[12];
        fileInputStream.read(vertexBytes);
        float x = ByteBuffer.wrap(vertexBytes, 0, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float y = ByteBuffer.wrap(vertexBytes, 4, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float z = ByteBuffer.wrap(vertexBytes, 8, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        triangle[v] = new float[]{x, y, z};

        // Check if vertex is already in the list
        if (!vertexIndexMap.containsKey(triangle[v])) {
          verticesList.add(triangle[v]);
          vertexIndexMap.put(triangle[v], verticesList.size() - 1);
        }
      }

      // Store edges as index pairs
      edgesList.add(new int[]{vertexIndexMap.get(triangle[0]), vertexIndexMap.get(triangle[1])});
      edgesList.add(new int[]{vertexIndexMap.get(triangle[1]), vertexIndexMap.get(triangle[2])});
      edgesList.add(new int[]{vertexIndexMap.get(triangle[2]), vertexIndexMap.get(triangle[0])});

      fileInputStream.skip(2); // Skip attribute byte count
    }
    fileInputStream.close();

    // Convert the vertices list to a float[][] array
    float[][] points = verticesList.toArray(new float[0][0]);

    // Convert the edges list to an int[][] array
    int[][] edges = edgesList.toArray(new int[0][0]);

    // Return an Nesh object containing the arrays
    return new Mesh(points, edges, calculateCentroid(points));
  }
}
