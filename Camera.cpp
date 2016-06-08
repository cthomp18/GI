/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Camera.h"

Camera::Camera(Eigen::Vector3f pos, Eigen::Vector3f u, Eigen::Vector3f r, Eigen::Vector3f lA) {
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
      
void Camera::move(Eigen::Vector3f pos) {
   position = pos;
}

void Camera::change(Eigen::Vector3f lA) {
   lookAt = lA;
}

Eigen::Vector3f Camera::getPosition() {
   return position;
}

Eigen::Vector3f Camera::getLookAt() {
   return lookAt;
}

Eigen::Vector3f Camera::getUp() {
   return up;
}

Eigen::Vector3f Camera::getRight() {
   return right;
}
