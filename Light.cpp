/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

/*
Supports:
   Point Lights
*/

#include "Light.h"

Light::Light(glm::vec3 pos, glm::vec3 col) {
   position = pos;
   color = col;
}

Light::Light() {
   //position = NULL;
   //color = NULL;
}

Light::~Light() {}
      
void Light::move(glm::vec3 pos) {
   position = pos;
}

void Light::changeColor(glm::vec3 col) {
   color = col;
}

glm::vec3 Light::getPosition() {
   return position;
}

glm::vec3 Light::getColor() {
   return color;
}
