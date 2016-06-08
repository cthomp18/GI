/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include <iostream>
#include "SceneObject.h"
#include "Collision.h"

using namespace std;

Collision::Collision(float t, SceneObject* s) {
   time = t;
   object = s;
}

Collision::Collision() {
   time = -1.0;
   object = NULL;
}

Collision::~Collision() {}

void Collision::detectRayCollision(Eigen::Vector3f start, Eigen::Vector3f ray, std::vector<SceneObject*> objects, int omitInd, bool unit) {
   float tempT;
   Eigen::Vector3f rayTransform;
   Eigen::Vector4f startTransform;
   startTransform << start, 1.0f;
   SceneObject *tempObject;
   time = -1.0;
   object = NULL;
   
   for (int i = 0; i < objects.size(); i++) {
      if (i == omitInd) continue;
      
      if (objects[i]->transformed) {
         tempT = objects[i]->checkCollision((objects[i]->transform * startTransform).segment<3>(0), objects[i]->transform.block<3,3>(0,0) * ray, 2.0f, &tempObject);
      } else {
         tempT = objects[i]->checkCollision(start, ray, 2.0f, &tempObject);
      }
      
      if (tempT < TOLERANCE) continue;
      
      if (object == NULL || tempT < time) {
         time = tempT;
         object = tempObject;
      }
   }
}
