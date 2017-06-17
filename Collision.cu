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
void Collision::detectRayCollisionHost(glm::vec3 start, glm::vec3 ray, thrust::host_vector<SceneObject*> objects, uint omitInd, bool unit) {
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
         tempT = objects[i]->checkCollision(objects[i], glm::vec3(objects[i]->transform * startTransform), glm::mat3(objects[i]->transform) * ray, 2.0f, &tempObject);
      } else {
         tempT = objects[i]->checkCollision(objects[i], start, ray, 2.0f, &tempObject);
      }
      
      if (tempT < TOLERANCE) continue;
      
      if (object == NULL || tempT < time) {
         time = tempT;
         object = tempObject;
      }
   }
}

void Collision::detectRayCollision(glm::vec3 start, glm::vec3 ray, SceneObject** objects, int objSize, float *shF, int *shI) {

   //F08: Temporary local

   //I01: Omit Index
   //I02: Object array size
   
   //NOTE: PLEASE SEE THE BELOW COMMENTED FUNCTION FOR BETTER VARIABLE USE AS COMPARISON

   SceneObject *tempObject;

   for (int i = 0; i < objSize; i++) {
      shF[8] = objects[i]->checkCollision(objects[i], start, ray, 2.0f, &tempObject);
      
      if (shF[8] < TOLERANCE) continue;
      
      if (object == NULL || shF[8] < time) {
         time = shF[8];
         object = tempObject;
      }
   }
}

void Collision::detectRayCollision2(glm::vec3 start, glm::vec3 ray, SceneObject** objects, int objSize, int omitInd, bool unit) {
   float tempT;
   glm::vec3 rayTransform;
   glm::vec4 startTransform;
   startTransform = glm::vec4(start, 1.0f);
   SceneObject *tempObject;
   Triangle *objs;
   //printf("???\n");
   //SceneObject **huh = &tempObject;
   //printf("ok...\n");
   time = -1.0;
   object = NULL;
   //printf("OBJSIZE: %d\n", objSize);
   //printf("OBJTYPE: %d\n", objects[0]->type);
   //printf("OBJ SIZE: %d\n", objSize);
   //for (int i = 0; i < objSize; i++) {
   //   if (!objects[i]) printf("FUCKKKK %d\n", i);
   //}
   for (int i = 0; i < objSize; i++) {
      if (i == omitInd) continue;
      
      if (objects[i]->transformed) {
         tempT = objects[i]->checkCollision(objects[i], glm::vec3(objects[i]->transform * startTransform), glm::mat3(objects[i]->transform) * ray, 2.0f, &tempObject);
      } else {
      /*printf("here\n");
      printf("%f, %f, %f\n", start.x, start.y, start.z);
      printf("%f, %f, %f\n", ray.x, ray.y, ray.z);
      printf("OBJSIZE: %d\n", objSize);
      printf("OBJTYPE: %d\n", objects[i]->type);*/
         //printf("hello\n");
         //if (objects[i]) { printf("UHHH\n"); }
         //else {printf("FUCK\n");}
         //printf("TYPE %d\n", objects[i]->type);
         //printf("ACTUAL FUNC LOC: %p\n", &checkOctTreeCollision);
         //printf("ACTUAL OTHER FUNC LOC: %p\n", &checkOctTreeCollision2);
         //printf("FUNC LOC: %p\n", objects[i]->checkCollision);
         //objs = reinterpret_cast<Triangle*>(objects[i]);
         //tempT = (objs + 190268)->checkCollision(objs + 190268, start, ray, 2.0f, &tempObject);
         //printf("PLEASE HERE\n");
         //printf("WE COLL %f %f %f\n", objects[0]->boundingBox.minPt.x, objects[0]->boundingBox.minPt.y, objects[0]->boundingBox.minPt.z);
         //printf("WE COLL %f %f %f\n", objects[0]->boundingBox.maxPt.x, objects[0]->boundingBox.maxPt.y, objects[0]->boundingBox.maxPt.z);
         tempT = objects[i]->checkCollision(objects[i], start, ray, 2.0f, &tempObject);
         //printf("k\n");
      }
      
      if (tempT < TOLERANCE) continue;
      
      if (object == NULL || tempT < time) {
         time = tempT;
         object = tempObject;
      }
   }
}
