/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Sphere.h"

Sphere::Sphere(Eigen::Vector3f pos, float rad) : SceneObject() {
   position = pos;
   radius = rad;
}

Sphere::Sphere() : SceneObject() {}
Sphere::~Sphere() {}

float Sphere::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   float t = -1.0f, t0, t1, innerRoot, A, B, C;

   A = ray.dot(ray);
   B = 2.0f * ((start - position).dot(ray));
   C = (start - position).dot(start - position) - (radius * radius);
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
}

Eigen::Vector3f Sphere::getNormal(Eigen::Vector3f iPt, float time) {
   return (iPt - position) / radius;
}

void Sphere::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - radius, position[1] - radius, position[2] - radius),
                         Eigen::Vector3f(position[0] + radius, position[1] + radius, position[2] + radius));
}
