/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "Camera.h"

Camera::Camera(glm::vec3 pos, glm::vec3 u, glm::vec3 r, glm::vec3 lA) {
   position = pos;
   up = u;
   right = r;
   lookAt = lA;
}

Camera::Camera() {
   /*position = NULL;
   up = NULL;
   right = NULL;
   lookAt = NULL;*/
}

Camera::~Camera() {}
      
void Camera::move(glm::vec3 pos) {
   position = pos;
}

void Camera::change(glm::vec3 lA) {
   lookAt = lA;
}

glm::vec3 Camera::getPosition() {
   return position;
}

glm::vec3 Camera::getLookAt() {
   return lookAt;
}

glm::vec3 Camera::getUp() {
   return up;
}

glm::vec3 Camera::getRight() {
   return right;
}
