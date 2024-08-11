float[][] z_buffer;

void drawGeometry(float[][] points, int[][] edges) {
  for (int[] edge : edges) {
    float[] P1 = points[edge[0]];
    float[] P2 = points[edge[1]];
    float[] p1 = proj2DTo3D(P1);
    float[] p2 = proj2DTo3D(P2);
    int p1_x = (int) p1[0];
    int p1_y = (int) p1[1];
    int p2_x = (int) p2[0];
    int p2_y = (int) p2[1];
    //idea: check if display-space pixel location is already being occupied by something with greater z-value (perhaps within threshold of distance?) before drawing, if so dont drawline
    //println(p1_x, p1_y, p2_x, p2_y);
    if (((p1_x >= 0 && p1_x < 1280 && p1_y >= 0 && p1_y < 720) && //if both point projections are within the display window,
        (p2_x >= 0 && p2_x < 1280 && p2_y >= 0 && p2_y < 720)) &&
        P1[2] <= z_buffer[p1_x][p1_y] && P2[2] <= z_buffer[p2_x][p2_y]){ //and this new line is the closest thing to the "camera" at that pixel...
      line(p1[0], p1[1], p2[0], p2[1]);//then draw it (but not otherwise)
      z_buffer[p1_x][p1_y] = P1[2];
      z_buffer[p2_x][p2_y] = P2[2];
    }
  }
}

void drawCube(float[] P1, float[] P2, float[] P3, float[] P4,
            float[] P5, float[] P6, float[] P7, float[] P8) {
  float[] p1 = proj2DTo3D(P1);
  float[] p2 = proj2DTo3D(P2);
  float[] p3 = proj2DTo3D(P3);
  float[] p4 = proj2DTo3D(P4);
  float[] p5 = proj2DTo3D(P5);
  float[] p6 = proj2DTo3D(P6);
  float[] p7 = proj2DTo3D(P7);
  float[] p8 = proj2DTo3D(P8);
  
  //line(x1, y1, x2, y2)
  stroke(#FF0D0D);
  line(p1[0], p1[1], p2[0], p2[1]);
  stroke(#229004);
  line(p2[0], p2[1], p3[0], p3[1]);
  stroke(#0D1AFF);
  line(p3[0], p3[1], p4[0], p4[1]);
  stroke(#1F1F1F);
  line(p4[0], p4[1], p1[0], p1[1]);
  stroke(#FF0D0D);
  line(p5[0], p5[1], p6[0], p6[1]);
  stroke(#229004);
  line(p6[0], p6[1], p7[0], p7[1]);
  stroke(#0D1AFF);
  line(p7[0], p7[1], p8[0], p8[1]);
  stroke(#1F1F1F);
  line(p8[0], p8[1], p4[0], p4[1]);
  
  stroke(#1F1F1F);
  line(p2[0], p2[1], p6[0], p6[1]);
  line(p3[0], p3[1], p7[0], p7[1]);
  line(p1[0], p1[1], p5[0], p5[1]);
  line(p8[0], p8[1], p5[0], p5[1]);
}

void drawSquare(float[] P1, float[] P2, float[] P3, float[] P4) {
  float[] p1 = proj2DTo3D(P1);
  float[] p2 = proj2DTo3D(P2);
  float[] p3 = proj2DTo3D(P3);
  float[] p4 = proj2DTo3D(P4);
  
  //line(x1, y1, x2, y2)
  stroke(#FF0D0D);
  line(p1[0], p1[1], p2[0], p2[1]);
  stroke(#229004);
  line(p2[0], p2[1], p3[0], p3[1]);
  stroke(#0D1AFF);
  line(p3[0], p3[1], p4[0], p4[1]);
  stroke(#1F1F1F);
  line(p4[0], p4[1], p1[0], p1[1]);
}

void drawTriangle(float[] P1, float[] P2, float[] P3) {
  float[] p1 = proj2DTo3D(P1);
  float[] p2 = proj2DTo3D(P2);
  float[] p3 = proj2DTo3D(P3);
  
  //line(x1, y1, x2, y2)
  stroke(#FF0D0D);
  line(p1[0], p1[1], p2[0], p2[1]);
  stroke(#229004);
  line(p2[0], p2[1], p3[0], p3[1]);
  stroke(#0D1AFF);
  line(p3[0], p3[1], p1[0], p1[1]);
}
