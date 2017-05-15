/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "Sphere.h"

Sphere::Sphere(glm::vec3 pos, float rad) : SceneObject() {
   position = pos;
   radius = rad;
   
   checkCollision = &(checkSphereCollision);
   getNormal = &(getSphereNormal);
}

Sphere::Sphere() : SceneObject() {}
Sphere::~Sphere() {}

/*float Sphere::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   float t = -1.0f, t0, t1, innerRoot, A, B, C;

   A = glm::dot(ray, ray);
   B = 2.0f * glm::dot(start - position, ray);
   C = glm::dot(start - position, start - position) - (radius * radius);
   innerRoot = (B * B) - (4.0f * A * C);
   
   if (innerRoot >= 0.0f) {
      t0 = (-B - sqrt(innerRoot)) / (2.0f * A);
      t1 = (-B + sqrt(innerRoot)) / (2.0f * A);
      if (t0 >= TOLERANCE && t0 < t1) {
         t = t0;
      } else if (t1 >= TOLERANCE) {
         t = t1;
      }
   }
   
   return t;
}*/

/*glm::vec3 Sphere::getNormal(glm::vec3 iPt, float time) {
   return (iPt - position) / radius;
}*/

void Sphere::constructBB() {
   boundingBox = BoundingBox(glm::vec3(position[0] - radius, position[1] - radius, position[2] - radius),
                             glm::vec3(position[0] + radius, position[1] + radius, position[2] + radius));
}
