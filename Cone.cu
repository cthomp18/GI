/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "Cone.h"

Cone::Cone(glm::vec3 endPt1, float rad1, glm::vec3 endPt2, float rad2) : SceneObject() {
   a = endPt1;
   radiusA = rad1;
   b = endPt2;
   radiusB = rad2;
}

Cone::Cone() : SceneObject() {}
Cone::~Cone() {}

float Cone::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   std::cout << "Cone Collision" << std::endl;
   
   return -1.0f;
}

glm::vec3 Cone::getNormal(glm::vec3 iPt, float time) {
   return glm::vec3(-1.0f, -1.0f, -1.0f);
}
