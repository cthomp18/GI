/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
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

void Collision::detectRayCollision(glm::vec3 start, glm::vec3 ray, std::vector<SceneObject*> objects, int omitInd, bool unit) {
   float tempT;
   glm::vec3 rayTransform;
   glm::vec4 startTransform;
   startTransform = glm::vec4(start, 1.0f);
   SceneObject *tempObject;
   time = -1.0;
   object = NULL;
   
   for (int i = 0; i < objects.size(); i++) {
      if (i == omitInd) continue;
      
      if (objects[i]->transformed) {
         tempT = objects[i]->checkCollision(glm::vec3(objects[i]->transform * startTransform), glm::mat3(objects[i]->transform) * ray, 2.0f, &tempObject);
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
