/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include <iostream>
#include "SceneObject.h"
#include "OctTreeNode.h"
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

//I need to make two equal collision detection functions because cuda #kms #fml
void Collision::detectRayCollision(glm::vec3 start, glm::vec3 ray, thrust::host_vector<SceneObject*> objects, uint omitInd, bool unit) {
   float tempT;
   glm::vec3 rayTransform;
   glm::vec4 startTransform;
   startTransform = glm::vec4(start, 1.0f);
   SceneObject *tempObject;
   time = -1.0;
   object = NULL;
   
   for (uint i = 0; i < objects.size(); i++) {
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

void Collision::detectRayCollision(glm::vec3 start, glm::vec3 ray, SceneObject** objects, int objSize, int omitInd, bool unit) {
   float tempT;
   glm::vec3 rayTransform;
   glm::vec4 startTransform;
   startTransform = glm::vec4(start, 1.0f);
   SceneObject *tempObject;
   //printf("???\n");
   //SceneObject **huh = &tempObject;
   printf("ok...\n");
   time = -1.0;
   object = NULL;
   //printf("OBJSIZE: %d\n", objSize);
   //printf("OBJTYPE: %d\n", objects[0]->type);
   for (int i = 0; i < objSize; i++) {
      if (i == omitInd) continue;
      
      if (objects[i]->transformed) {
         tempT = objects[i]->checkCollision(glm::vec3(objects[i]->transform * startTransform), glm::mat3(objects[i]->transform) * ray, 2.0f, &tempObject);
      } else {
      /*printf("here\n");
      printf("%f, %f, %f\n", start.x, start.y, start.z);
      printf("%f, %f, %f\n", ray.x, ray.y, ray.z);
      printf("OBJSIZE: %d\n", objSize);
      printf("OBJTYPE: %d\n", objects[i]->type);*/
         printf("hello\n");
         tempT = objects[i]->checkCollision(start, ray, 2.0f, &tempObject);
         printf("k\n");
      }
      
      if (tempT < TOLERANCE) continue;
      
      if (object == NULL || tempT < time) {
         time = tempT;
         object = tempObject;
      }
   }
}
