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

/*float checkOctTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   //printf("%f %f %f\n", start.x, start.y, start.z);
   //printf("%f %f %f\n", ray.x, ray.y, ray.z);
   //printf("otree collision\n");
   //printf("PARAM MEM: %p\n", obj);
   //return -1.0f;
   //printf("pls\n");
   glm::vec3 start(shF[6], shF[7], shF[8]);
   glm::vec4 startTransform;
   float t, tempT;
   //int i;
   SceneObject* tempObj;
   t = tempT = -1.0f;
   //obj = (SceneObject *)0xb0b8e4628;
   OctTreeNode *thisObj = reinterpret_cast<OctTreeNode*>(obj);
   //printf("Wanted to make sure\n");
   SceneObject **octants = thisObj->octants;
   int *indeces = thisObj->indeces;
   //if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   
   //printf("CURRENT MEM: %p\n", thisObj);
   //int pf = printf("Type? %d\n", thisObj->type);
   //printf("%d\n", pf);
   //printf("blah? %d\n", thisObj->blahblah);
   //printf("amb? %f\n", thisObj->ambient);
   //printf("is it here?\n");
   
   if (thisObj->boundingBox.checkCollision(start, ray, 0.0f) < TOLERANCE) { 
      //printf("%f %f %f\n", thisObj->boundingBox.minPt.x, thisObj->boundingBox.minPt.y, thisObj->boundingBox.minPt.z);
      //printf("%f %f %f\n", thisObj->boundingBox.maxPt.x, thisObj->boundingBox.maxPt.y, thisObj->boundingBox.maxPt.z);
      //printf("bb not hit\n");
      return -1.0f; 
   }
   //printf("nope\n");
   //if (octants[0] == NULL) {
   //   printf("roll up in the club\n");
   //} else {
   //   printf("yoyoyo\n");
   //}
   
   if (octants[0]) {
      //printf("weird\n");
      if (octants[0]->transformed) {
         //printf("where is it\n");
         //t = octants[0]->checkCollision(octants[0], glm::vec3(octants[0]->transform * startTransform), glm::mat3(thisObj->octants[0]->transform) * ray, time, &tempObj, shI, shF);
      } else {
         
         //printf("ok...\n");
         
         //pf = printf("Type octant? %d\n", octants[0]->type);
         //printf("%d\n", pf);
         //printf("BLAH octant? %d\n", octants[0]->blahblah);
         //printf("AMBi octant? %f\n", octants[0]->ambient);
         
         //octants[0]->type = 8;
         //octants[0]->blahblah = 1;
         //octants[0]->ambient = 4.0f;

         //printf("OCTANT MEM: %p\n", octants[0]);
         //printf("MORE OCTANT MEM: %p\n", thisObj + 1);
         //printf("THIS COLL MEM: %p\n", thisObj->checkCollision);
         //printf("OCTANT COLL MEM: %p\n", octants[0]->checkCollision);
         //printf("OCT COLL MEM: %p\n", &(checkOctTreeCollision));
         //printf("TRI COLL MEM: %p\n", &(checkTriCollision));
         
         //for (int i = 0; i < 8; i++) {
         //   printf("INDEX %d: %d\n", i, indeces[i]);
         //}
         
         //SETTING COLLISION FUNC PTR TO EQUIVALENT FUNCTION
         
         //octants[0]->checkCollision = &(checkOctTreeCollision2);
         
         //printf("OCTANT COLL MEM: %p\n", octants[0]->checkCollision);
         //printf("RANDOM\n");
         //printf("FILLER\n");
         //printf("STUFF\n");
         //printf("TO\n");
         //printf("SEE\n");
         //printf("IF\n");
         //printf("ITS\n");
         //printf("BAD\n");
         //printf("PARAM MEM AGAIN: %p\n", obj);
         
         
         // CALLING SECOND HERE
         // AFTER THIS IT WILL CRASH
         
         //octants[0] = (SceneObject*)0xb085e09a8;
         //printf("NEW TYPE: %d\n", octants[0]->type);
         t = octants[0]->checkCollision(octants[0], ray, &tempObj, shI, shF);
      }
   }
   *object = tempObj;
   //printf("t: %f\n", t);
   //printf("Type? %d\n", thisObj->type);
   //if (octants[1]) {
   //   printf("anything, really\n");
   //} else {
   //   printf("pls\n");
   //}
   //printf("looking for something\n");
   
   int i = 0;
   
   // SAME AS ABOVE, BUT FOR THE OTHER 7 OCTANTS
   
   for (i = 1; i < 8; i++) {
      //printf("please\n");
      if (octants[i]) {
      //printf("yo\n");
         if (t >= 0.001) {
            //printf("hi\n");
            tempT = octants[i]->boundingBox.checkCollision(start, ray, 0.0f);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  //tempT = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj, shI, shF);
               } else {
                  //printf("yo dawg\n");
                  if (octants[i]->type != 8) {
                     //printf("triangle starting\n");
                  }
                  
                  
                  tempT = octants[i]->checkCollision(octants[i], ray, &tempObj, shI, shF);
                  //printf("TTEMP : %f\n", tempT);
                  
                  //printf("k\n");
                  //if (octants[i]->type != 8) {
                  //   printf("triangle ending\n");
                  //}
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  //printf("T : %f\n", t);
                  *object = tempObj;
               }
            }
         } else {
            //octants[i] = (SceneObject*)0xb085e09a8;
            //t = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj, shI, shF);
            //printf("T : %f\n", t);
            //t = octants[i]->checkCollision(octants[i], start, ray, time, &tempObj);
            *object = tempObj;
         }
      } //else break();
      //printf("sup fam\n");
   }
   //printf("whats happening\n");
   if (t < TOLERANCE) {
      *object = NULL;
   }
   //printf("END T : %f\n", t);
   return t;
}*/

//See more detailed function below
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

/*float checkTriCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   //printf("Triangle Collision\n");
   glm::mat3 A, Ai;
   double detA, t, beta, gamma;
   Triangle *thisObj = reinterpret_cast<Triangle*>(obj);
   *object = obj;
   glm::vec3 a = thisObj->a;
   glm::vec3 b = thisObj->b;
   glm::vec3 c = thisObj->c;
   
   A = glm::mat3(a.x - b.x, a.x - c.x, ray.x,
                 a.y - b.y, a.y - c.y, ray.y,
                 a.z - b.z, a.z - c.z, ray.z);

   detA = glm::determinant(A);
   
   Ai = A;
   Ai[0][2] = thisObj->a.x - start.x; Ai[1][2] = thisObj->a.y - start.y; Ai[2][2] = thisObj->a.z - start.z;
   t = glm::determinant(Ai) / detA;
   if (t > TOLERANCE) {
      Ai = A;
      Ai[0][0] = thisObj->a.x - start.x; Ai[1][0] = thisObj->a.y - start.y; Ai[2][0] = thisObj->a.z - start.z;
      gamma = glm::determinant(Ai) / detA;
      if (gamma >= 0.0f && gamma <= 1.0f) {
         Ai = A;
         Ai[0][1] = thisObj->a.x - start.x; Ai[1][1] = thisObj->a.y - start.y; Ai[2][1] = thisObj->a.z - start.z;
         beta = glm::determinant(Ai) / detA;
         if (beta >= 0.0f && beta + gamma <= 1.0f) {
            *object = obj;            
            return t;
         }
      }
   }
   
   return -1.0f;
}*/

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

/*float checkPlaneCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   float t = -1.0f, dotProd;
   Plane *thisObj = reinterpret_cast<Plane*>(obj);

   dotProd = glm::dot(ray, thisObj->normal);
   
   if (dotProd != 0.0f) {
      t = glm::dot(thisObj->planePt - start, thisObj->normal) / glm::dot(ray, thisObj->normal);
   }
   
   *object = obj;
   return t;
}*/

//float checkBiTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
float checkBiTreeCollision(SceneObject *obj, glm::vec3 ray, SceneObject** object, int *shI, float *shF) {
   glm::vec4 startTransform;
   glm::vec3 start(shF[6], shF[7], shF[8]);
   float t, tLeft, tRight;
   SceneObject *lObj, *rObj;
   t = tLeft = tRight = -1.0f;
   BiTreeNode *thisObj = reinterpret_cast<BiTreeNode*>(obj);
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (thisObj->boundingBox.checkCollision(start, ray, 0.0f) < TOLERANCE) return -1.0f;
   //if (left) {
   if (thisObj->left->transformed) {
      //tLeft = thisObj->left->checkCollision(thisObj->left, glm::vec3(thisObj->left->transform * startTransform), glm::mat3(thisObj->left->transform) * ray, time, &lObj, shI, shF);
   } else {
      tLeft = thisObj->left->checkCollision(thisObj->left, ray, &lObj, shI, shF);
   }
   if (thisObj->right) {
      if (tLeft >= TOLERANCE) {
         tRight = thisObj->right->boundingBox.checkCollision(start, ray, 0.0f);
         if (tRight >= TOLERANCE && tRight < tLeft) {
            if (thisObj->right->transformed) {
               //tRight = thisObj->right->checkCollision(thisObj->right, glm::vec3(thisObj->right->transform * startTransform), glm::mat3(thisObj->right->transform) * ray, time, &rObj, shI, shF);
            } else {
               tRight = thisObj->right->checkCollision(thisObj->right, ray, &rObj, shI, shF);
            }
         } else {
            tRight = -1.0f;
         }
      } else {
         //tRight = thisObj->right->checkCollision(thisObj->right, glm::vec3(thisObj->right->transform * startTransform), glm::mat3(thisObj->right->transform) * ray, time, &rObj, shI, shF);
         tRight = thisObj->right->checkCollision(thisObj->right, ray, &rObj, shI, shF);
      }
   }
   //}
   
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

//float checkBoxCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
float checkBoxCollision(SceneObject *obj, glm::vec3 ray, SceneObject **object, int *shI, float *shF) {
   //std::cout << "Box Collision" << std::endl;
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
   
   /*if (start.x() >= minPt.x() && start.x() <= maxPt.x() &&
       start.y() >= minPt.y() && start.y() <= maxPt.y() && 
       start.z() >= minPt.z() && start.z() <= maxPt.z()) {
       t = 10.0f;
       
       std::cout << "Inside!!!" << std::endl;
   }*/
   //if (tgmin < TOLERANCE) return new Collision(tgmin, this);
   //if (tgmin > tgmax || tgmax < 0.001f) return new Collision(t, this);
   
   *object = obj;
   
   if (tgmin > tgmax) return -1.0f;
   if (tgmin < TOLERANCE) return tgmax;
   return tgmin;
}

//float checkQuadTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
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

//See original below
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

/*float checkSphereCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   volatile float t, t0 = -1.0f, t1 = -1.0f, A, B, C;
   
   Sphere *thisObj = reinterpret_cast<Sphere*>(obj);
   volatile float radius = thisObj->radius;
   glm::vec3 position = thisObj->position;
   float A, B, C;
   
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
   
   *object = obj;
   return t0;
}*/

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
