/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Cone.h"

Cone::Cone(Eigen::Vector3f endPt1, float rad1, Eigen::Vector3f endPt2, float rad2) : SceneObject() {
   a = endPt1;
   radiusA = rad1;
   b = endPt2;
   radiusB = rad2;
}

Cone::Cone() : SceneObject() {}
Cone::~Cone() {}

float Cone::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   std::cout << "Cone Collision" << std::endl;
   
   return -1.0f;
}

Eigen::Vector3f Cone::getNormal(Eigen::Vector3f iPt, float time) {
   return Eigen::Vector3f(-1.0f, -1.0f, -1.0f);
}
