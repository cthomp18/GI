/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

/*
Supports:
   Point Lights
*/

#include <Eigen/Dense>
#include "Light.h"

Light::Light(Eigen::Vector3f pos, Eigen::Vector3f col) {
   position = pos;
   color = col;
}

Light::Light() {
   //position = NULL;
   //color = NULL;
}

Light::~Light() {}
      
void Light::move(Eigen::Vector3f pos) {
   position = pos;
}

void Light::changeColor(Eigen::Vector3f col) {
   color = col;
}

Eigen::Vector3f Light::getPosition() {
   return position;
}

Eigen::Vector3f Light::getColor() {
   return color;
}
