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
      for (int[] face : faces) {
        List<float[]> facePoints = new ArrayList<>();
        for (int point : face) {
          facePoints.add(points[point]);
        }
        faceList.add(new Face(facePoints));
      }
      this.faces = faceList.toArray(new Face[0]);
      this.centroid = calculateCentroid(this.faces);
    }
    // Copy constructor for Mesh
    public Mesh(Mesh otherMesh) {
      this.faces = new Face[otherMesh.faces.length];
      for (int i = 0; i < otherMesh.faces.length; i++) {
        this.faces[i] = new Face(otherMesh.faces[i]); // Use the copy constructor for Face
      }
      this.centroid = otherMesh.centroid.clone();
    }
  }

  public static class Face {
    public List<float[]> points;
    public float[] normal;
    //public float[] fragmentToViewer;

    public Face(List<float[]> points, float[] normal) {
      this.points = points;
      //this.fragmentToViewer = points.get(0);
      this.normal = vect3normalize(normal);
    }
    public Face(List<float[]> points) {
      this.points = points;
      //this.fragmentToViewer = points.get(0);
      this.normal = vect3normalize(calculateNorm(points));
    }
    // Copy constructor for Face
    public Face(Face otherFace) {
      // Create a deep copy of the points list
      this.points = new ArrayList<>();
      for (float[] point : otherFace.points) {
        this.points.add(point.clone()); // Clone each point (float[] array)
      }

      // Clone the normal array
      this.normal = otherFace.normal.clone();
    }
  }

  public static class Plane extends Face {
    public float D;//plane constant: dot(normal, P_0)

    public Plane (float[] point, float[] normal) {
      super(new ArrayList<>(Arrays.asList(point)), normal); // Call the Face constructor
      this.D = dotProd(normal, points.get(0));
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

      List<float[]> triangle = new ArrayList<>();
      for (int v = 0; v < 3; v++) {
        byte[] vertexBytes = new byte[12];
        fileInputStream.read(vertexBytes);
        float x = ByteBuffer.wrap(vertexBytes, 0, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float y = ByteBuffer.wrap(vertexBytes, 4, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        float z = ByteBuffer.wrap(vertexBytes, 8, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        triangle.add(new float[]{x, y, z});

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

  // Method to parse the OBJ file and return a Mesh object
  public static Mesh parseOBJ(String filename) throws IOException {
    BufferedReader reader = new BufferedReader(new FileReader(filename));

    List<float[]> vertices = new ArrayList<>();
    List<Face> faces = new ArrayList<>();

    String line;

    while ((line = reader.readLine()) != null) {
      String[] tokens = line.split("\\s+");

      if (tokens[0].equals("v")) {
        // Vertex definition
        float x = Float.parseFloat(tokens[1]);
        float y = Float.parseFloat(tokens[2]);
        float z = Float.parseFloat(tokens[3]);
        vertices.add(new float[]{x, y, z});
      } else if (tokens[0].equals("f")) {
        // Face definition
        List<float[]> faceVertices = new ArrayList<>();

        for (int i = 1; i < tokens.length; i++) {
          String[] vertexData = tokens[i].split("/");
          int vertexIndex = Integer.parseInt(vertexData[0]) - 1; // OBJ is 1-based indexing
          faceVertices.add(vertices.get(vertexIndex));
        }

        // Create a face with the vertices
        Face face = new Face(faceVertices);
        faces.add(face);
      }
    }

    reader.close();

    // Convert the list of faces to an array
    Face[] faceArray = faces.toArray(new Face[0]);

    // Return a Mesh object
    return new Mesh(faceArray);
  }

  public static float[] calculateCentroid(Mesh mesh) {
    return calculateCentroid(mesh.faces);
  }

  public static float[] calculateCentroid(Face[] faces) {
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

  public static void applyTransformations(MeshBuilder.Mesh mesh, float[] translation, float rotationX, float rotationY, float rotationZ) {
    Map<String, float[]> uniquePoints = new HashMap<>();
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.size(); i++) {
        float[] point = face.points.get(i);
        String pointKey = point[0] + "," + point[1] + "," + point[2];

        // Apply X rotation if specified
        if (rotationX != 0) {
          face.points.set(i, apply3DRotationX(face.points.get(i), mesh.centroid, rotationX));
        }
        // Apply Y rotation if specified
        if (rotationY != 0) {
          face.points.set(i, apply3DRotationY(face.points.get(i), mesh.centroid, rotationY));
        }
        // Apply Z rotation if specified
        if (rotationZ != 0) {
          face.points.set(i, apply3DRotationZ(face.points.get(i), mesh.centroid, rotationZ));
        }
        // Apply translation
        if (translation != null) {
          face.points.set(i, apply3DTranslation(face.points.get(i), translation));
        }
        uniquePoints.put(pointKey, point);
      }
      // Update the normal vector if necessary
      if (rotationX != 0) {
        face.normal = apply3DRotationX(face.normal, new float[] {0, 0, 0}, rotationX);
      }
      if (rotationY != 0) {
        face.normal = apply3DRotationY(face.normal, new float[] {0, 0, 0}, rotationY);
      }
      if (rotationZ != 0) {
        face.normal = apply3DRotationZ(face.normal, new float[] {0, 0, 0}, rotationZ);
      }
    }
    // Update the centroid with the translation
    if (translation != null) {
      mesh.centroid = apply3DTranslation(mesh.centroid, translation);
    }
  }

  public static void applyScaling(MeshBuilder.Mesh mesh, float scaleX, float scaleY, float scaleZ) {
    for (MeshBuilder.Face face : mesh.faces) {
      for (int i = 0; i < face.points.size(); i++) {
        // Get the original point
        float[] point = face.points.get(i);

        // Apply scaling by multiplying each coordinate by the corresponding scaling factor
        float[] scaledPoint = new float[] {
          point[0] * scaleX,
          point[1] * scaleY,
          point[2] * scaleZ
        };

        // Update the point with the scaled values
        face.points.set(i, scaledPoint);
      }
    }

    // Optionally, scale the centroid of the mesh as well
    mesh.centroid = new float[] {
      mesh.centroid[0] * scaleX,
      mesh.centroid[1] * scaleY,
      mesh.centroid[2] * scaleZ
    };
  }
}
