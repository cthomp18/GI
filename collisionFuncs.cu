#include "collisionFuncs.h"

float checkOctTreeCollision(SceneObject *obj, glm::vec3 ray, SceneObject** object, int *shI, float *shF) {
   //start
   //F6-F8: start vector

   glm::vec3 start(shF[6], shF[7], shF[8]);
   float t, tempT;
   SceneObject* tempObj;
   t = tempT = -1.0f;
   OctTreeNode *thisObj = reinterpret_cast<OctTreeNode*>(obj);
   SceneObject **octants = thisObj->octants;
   
   if (thisObj->boundingBox.checkCollision(ray, 0.0f, shI, shF) < TOLERANCE) { 
      return -1.0f; 
   }
   
   for (int i = 0; i < 8; i++) {
      if (octants[i]) {
         if (t >= 0.001) {
            tempT = octants[i]->boundingBox.checkCollision(ray, 0.0f, shI, shF);
            if (tempT >= TOLERANCE && tempT < t) {
               tempT = octants[i]->checkCollision(octants[i], ray, &tempObj, shI, shF);
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = tempObj;
               }
            }
         } else {
            t = octants[i]->checkCollision(octants[i], ray, &tempObj, shI, shF);
            *object = tempObj;
         }
      }
   }
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;
}

float checkTriCollision(SceneObject *obj, glm::vec3 ray, SceneObject** object, int *shI, float *shF) {
   //start
   //F6-F8: start vector
   //
   //mid
   //F5: time
   //F6: beta
   //F7: gamma
   //F8: determinant of original A matrix

   volatile glm::vec3 start(shF[6], shF[7], shF[8]);
   glm::mat3 A;
   volatile Triangle *thisObj = reinterpret_cast<volatile Triangle*>(obj);
   *object = obj;
   
   A = glm::mat3(thisObj->a.x - thisObj->b.x, thisObj->a.x - thisObj->c.x, ray.x,
                 thisObj->a.y - thisObj->b.y, thisObj->a.y - thisObj->c.y, ray.y,
                 thisObj->a.z - thisObj->b.z, thisObj->a.z - thisObj->c.z, ray.z);
   shF[8] = glm::determinant(A);
   
   A[0][2] = thisObj->a.x - start.x; A[1][2] = thisObj->a.y - start.y; A[2][2] = thisObj->a.z - start.z;
   shF[5] = glm::determinant(A) / shF[8];
   A[0][2] = ray.x; A[1][2] = ray.y; A[2][2] = ray.z;
   if (shF[5] > TOLERANCE) {
      A[0][0] = thisObj->a.x - start.x; A[1][0] = thisObj->a.y - start.y; A[2][0] = thisObj->a.z - start.z;
      shF[7] = glm::determinant(A) / shF[8];
      A[0][0] = thisObj->a.x - thisObj->b.x; A[1][0] = thisObj->a.y - thisObj->b.y; A[2][0] = thisObj->a.z - thisObj->b.z;
      if (shF[7] >= 0.0f && shF[7] <= 1.0f) {
         A[0][1] = thisObj->a.x - start.x; A[1][1] = thisObj->a.y - start.y; A[2][1] = thisObj->a.z - start.z;
         shF[6] = glm::determinant(A) / shF[8];
         if (shF[6] >= 0.0f && shF[6] + shF[7] <= 1.0f) {
            shF[6] = start.x;
            shF[7] = start.y;
            shF[8] = start.z;
            
            return shF[5];
         }
      }
   }
   
   shF[6] = start.x;
   shF[7] = start.y;
   shF[8] = start.z;
               
   return -1.0f;
}

//See more detailed function below
float checkPlaneCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   //F5: time
   //F6-F8: start vector
   
   *object = obj;
   shF[5] = -1.0f;
   volatile Plane *thisObj = reinterpret_cast<volatile Plane*>(obj);
   volatile float dotProd = ray.x * thisObj->normal.x + ray.y * thisObj->normal.y + ray.z * thisObj->normal.z;

   volatile glm::vec3 newpt;
   newpt.x = thisObj->planePt.x - shF[6];
   newpt.y = thisObj->planePt.y - shF[7];
   newpt.z = thisObj->planePt.z - shF[8];
   
   if (dotProd != 0.0f) {
      shF[5] = (newpt.x * thisObj->normal.x + newpt.y * thisObj->normal.y + newpt.z * thisObj->normal.z) / dotProd;
   }
   
   return shF[5];
}


float checkBiTreeCollision(SceneObject *obj, glm::vec3 ray, SceneObject** object, int *shI, float *shF) {
   glm::vec4 startTransform;
   glm::vec3 start(shF[6], shF[7], shF[8]);
   float t, tLeft, tRight;
   SceneObject *lObj, *rObj;
   t = tLeft = tRight = -1.0f;
   BiTreeNode *thisObj = reinterpret_cast<BiTreeNode*>(obj);
   
   startTransform = glm::vec4(start, 1.0f);
   if (thisObj->boundingBox.checkCollision(start, ray, 0.0f) < TOLERANCE) return -1.0f;
   
   tLeft = thisObj->left->checkCollision(thisObj->left, ray, &lObj, shI, shF);
   if (thisObj->right) {
      if (tLeft >= TOLERANCE) {
         tRight = thisObj->right->boundingBox.checkCollision(start, ray, 0.0f);
         if (tRight >= TOLERANCE && tRight < tLeft) {
            tRight = thisObj->right->checkCollision(thisObj->right, ray, &rObj, shI, shF);
         } else {
            tRight = -1.0f;
         }
      } else {
         tRight = thisObj->right->checkCollision(thisObj->right, ray, &rObj, shI, shF);
      }
   }
   
   if (tLeft < TOLERANCE) {
      if (tRight >= TOLERANCE) {
         t = tRight;
         *object = rObj;
      }
   } else {
      if (tRight < TOLERANCE) {
         t = tLeft;
         *object = lObj;
      } else {
         if (tLeft < tRight) {
            t = tLeft;
            *object = lObj;
         } else {
            t = tRight;
            *object = rObj;
         }
      }
   }
   
   *object = obj;
   return t;
}

float checkBoxCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   glm::vec3 start(shF[6], shF[7], shF[8]);
   float tgmin = FLT_MIN, tgmax = FLT_MAX, t1, t2, temp, t = -1.0f;
   Box *thisObj = reinterpret_cast<Box*>(obj);
   glm::vec3 maxPt = thisObj->maxPt;
   glm::vec3 minPt = thisObj->minPt;
   
   for (int i = 0; i < 3; i++) {
      temp = start[i];
      
      if (fabs(ray[i]) < TOLERANCE) { // Ray along 2D Plane checks
         if (temp > maxPt[i] || temp < minPt[i]) return -1.0f;
      }
      
      t1 = (minPt[i] - temp) / ray[i];
      t2 = (maxPt[i] - temp) / ray[i];
      if (t2 < t1) {
         temp = t2;
         t2 = t1;
         t1 = temp;
      }
      if (t1 > tgmin) tgmin = t1;
      if (t2 < tgmax) tgmax = t2;
   }
   
   *object = obj;
   
   if (tgmin > tgmax) return -1.0f;
   if (tgmin < TOLERANCE) return tgmax;
   return tgmin;
}

float checkQuadTreeCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   //start
   //F6-F8: start vector
   
   float t, tempT;
   SceneObject *tempObj;
   t = tempT = -1.0f;
   QuadTreeNode *thisObj = reinterpret_cast<QuadTreeNode*>(obj);
   SceneObject **quadrants = thisObj->quadrants;

   if (thisObj->boundingBox.checkCollision(ray, 0.0f, shI, shF) < TOLERANCE) {
      return -1.0f;
   }
   
   for (int i = 0; i < 4; i++) {
      if (quadrants[i]) {
         if (t >= TOLERANCE) {
            tempT = quadrants[i]->boundingBox.checkCollision(ray, 0.0f, shI, shF);
            if (tempT >= TOLERANCE && tempT < t) {
               tempT = quadrants[i]->checkCollision(quadrants[i], ray, &tempObj, shI, shF);
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = tempObj;
               }
            }
         } else {
            t = quadrants[i]->checkCollision(quadrants[i], ray, &tempObj, shI, shF);
            *object = tempObj;
         }
      }
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;
}

float checkSphereCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   //start
   //F6-F8: start vector
   //
   //mid
   //F5: inner root
   //F6: A
   //F7: B
   //F8: C
   
   glm::vec3 start(shF[6], shF[7], shF[8]);
   volatile float t0 = -1.0f, t1 = -1.0f;
   
   Sphere *thisObj = reinterpret_cast<Sphere*>(obj);
   volatile float radius = thisObj->radius;
   glm::vec3 position = thisObj->position;
   
   shF[6] = glm::dot(ray, ray);
   shF[7] = 2.0f * glm::dot(start - position, ray);
   shF[8] = glm::dot(start - position, start - position) - (radius * radius);
   shF[5] = (shF[7] * shF[7]) - (4.0f * shF[6] * shF[8]);
   
   if (shF[5] >= 0.0f) {
      t0 = (-shF[7] - sqrt(shF[5])) / (2.0f * shF[6]);
      t1 = (-shF[7] + sqrt(shF[5])) / (2.0f * shF[6]);
      if (t1 >= TOLERANCE && t1 < t0) {
         t0 = t1;
      }
   }
   
   shF[6] = start.x;
   shF[7] = start.y;
   shF[8] = start.z;
   
   *object = obj;
   return t0;
}

//float checkGWCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
float checkGWCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   printf("GW Collision\n");
   *object = obj;
   return -1.0f;
}

//float checkConeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
float checkConeCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   printf("Cone Collision\n");
   *object = obj;
   return -1.0f;
}
