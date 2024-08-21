/***Cube data***/
float[][] cubePoints = {
  {-1, -1, 40}, // 0
  {-1, 1, 40}, // 1
  {1, 1, 40}, // 2
  {1, -1, 40}, // 3
  {-1, -1, 42}, // 4
  {-1, 1, 42}, // 5
  {1, 1, 42}, // 6
  {1, -1, 42} // 7
};

// Define faces using counterclockwise order when viewed from the outside
int[][] cubeFaces = {
  {0, 1, 2, 3}, // Front face (counterclockwise when viewed from outside)
  {7, 6, 5, 4}, // Back face
  {0, 3, 7, 4}, // Bottom face
  {1, 5, 6, 2}, // Top face
  {0, 4, 5, 1}, // Left face
  {3, 2, 6, 7}  // Right face
};
/***END cube data***/

/*Depricated mesh data
 //(0, 0, 0) is top left (behind the camera)
 float[][] trianglePoints = {
 {17, 3, 60},
 {15, 5, 75},
 {16, 5, 65}
 };
 float[][] squarePoints = {
 {10, 10, 60},
 {10, 5, 60},
 {15, 5, 60},
 {15, 10, 60}
 };
 */
