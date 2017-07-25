/*
   Cody Thompson
   Thesis
   Winter 2017
*/

#include "Box.h"

BoundingBox::BoundingBox(glm::vec3 cornerPt1, glm::vec3 cornerPt2) {
   for (int i = 0; i < 3; i++) {
      if (cornerPt1[i] < cornerPt2[i]) {
         minPt[i] = cornerPt1[i];
         maxPt[i] = cornerPt2[i];
      } else {
         minPt[i] = cornerPt2[i];
         maxPt[i] = cornerPt1[i];
      }
   }
   middle = glm::vec3((maxPt[0] + minPt[0]) / 2.0f, (maxPt[1] + minPt[1]) / 2.0f, (maxPt[2] + minPt[2]) / 2.0f);
}

BoundingBox::BoundingBox() {}
BoundingBox::~BoundingBox() {}

float BoundingBox::checkCollision(glm::vec3 ray, float time, int *shI, float *shF) {
   float tgmin = FLT_MIN, tgmax = FLT_MAX, t1, t2, temp, t = -1.0f;
   glm::vec3 start(shF[6], shF[7], shF[8]);
   for (int i = 0; i < 3; i++) {
      temp = start[i];
      
      if (fabs(ray[i]) < TOLERANCE) { // Ray along 2D Plane checks
         if (temp > maxPt[i] || temp < minPt[i]) return -1.0f;
      }
      
      t1 = (minPt[i] - temp) / ray[i];
      t2 = (maxPt[i] - temp) / ray[i];
      if (t2 < t1) {
         temp = t2;
         t2 = t1;
         t1 = temp;
      }
      if (t1 > tgmin) tgmin = t1;
      if (t2 < tgmax) tgmax = t2;
   }
   
   if (tgmin > tgmax) return -1.0f;
   if (tgmin < TOLERANCE) return tgmax;
   return tgmin;
}

float BoundingBox::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   //std::cout << "Box Collision" << std::endl;
   float tgmin = FLT_MIN, tgmax = FLT_MAX, t1, t2, temp, t = -1.0f;

   for (int i = 0; i < 3; i++) {
      temp = start[i];
      
      if (fabs(ray[i]) < TOLERANCE) { // Ray along 2D Plane checks
         if (temp > maxPt[i] || temp < minPt[i]) return -1.0f;
      }
      
      t1 = (minPt[i] - temp) / ray[i];
      t2 = (maxPt[i] - temp) / ray[i];
      if (t2 < t1) {
         temp = t2;
         t2 = t1;
         t1 = temp;
      }
      if (t1 > tgmin) tgmin = t1;
      if (t2 < tgmax) tgmax = t2;
   }
   
   /*if (start.x() >= minPt.x() && start.x() <= maxPt.x() &&
       start.y() >= minPt.y() && start.y() <= maxPt.y() && 
       start.z() >= minPt.z() && start.z() <= maxPt.z()) {
       t = 10.0f;
       
       std::cout << "Inside!!!" << std::endl;
   }*/
   //if (tgmin < TOLERANCE) return new Collision(tgmin, this);
   //if (tgmin > tgmax || tgmax < 0.001f) return new Collision(t, this);
   if (tgmin > tgmax) return -1.0f;
   if (tgmin < TOLERANCE) return tgmax;
   return tgmin;
}
