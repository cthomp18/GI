/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Box.h"


Box::Box(Eigen::Vector3f cornerPt1, Eigen::Vector3f cornerPt2) : SceneObject() {
   for (int i = 0; i < 3; i++) {
      if (cornerPt1[i] < cornerPt2[i]) {
         minPt[i] = cornerPt1[i];
         maxPt[i] = cornerPt2[i];
      } else {
         minPt[i] = cornerPt2[i];
         maxPt[i] = cornerPt1[i];
      }
   }
   middle = Eigen::Vector3f((maxPt[0] + minPt[0]) / 2.0f, (maxPt[1] + minPt[1]) / 2.0f, (maxPt[2] + minPt[2]) / 2.0f);
   unit = false;
}

Box::Box() : SceneObject() {}
Box::~Box() {}

float Box::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
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

Eigen::Vector3f Box::getNormal(Eigen::Vector3f iPt) {
   Eigen::Vector3f normal = Eigen::Vector3f(0.0f, 0.0f, 0.0f);
   
   for (int i = 0; i < 3; i++) {
      if (fabs(iPt[i] - minPt[i]) < TOLERANCE) {
         normal[i] = -1.0f;
      } else if (fabs(iPt[i] - maxPt[i]) < TOLERANCE) {
         normal[i] = 1.0f;
      }
   }
   
   return normal;
}

void Box::constructBB() {
   boundingBox = new Box(minPt, maxPt);
}
