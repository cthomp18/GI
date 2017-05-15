#include "collisionFuncs.h"

float checkOctTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
/*printf("%f %f %f\n", start.x, start.y, start.z);
printf("%f %f %f\n", ray.x, ray.y, ray.z);
printf("otree collision\n");*/
//printf("PARAM MEM: %p\n", obj);
//return -1.0f;
   //printf("pls\n");
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
   
   
   /*printf("CURRENT MEM: %p\n", thisObj);
   int pf = printf("Type? %d\n", thisObj->type);
   printf("%d\n", pf);
   printf("blah? %d\n", thisObj->blahblah);
   printf("amb? %f\n", thisObj->ambient);
   printf("is it here?\n");*/
   
   
   if (thisObj->boundingBox.checkCollision(start, ray, time) < TOLERANCE) { 
      /*printf("%f %f %f\n", thisObj->boundingBox.minPt.x, thisObj->boundingBox.minPt.y, thisObj->boundingBox.minPt.z);
      printf("%f %f %f\n", thisObj->boundingBox.maxPt.x, thisObj->boundingBox.maxPt.y, thisObj->boundingBox.maxPt.z);
      printf("bb not hit\n"); */
      return -1.0f; 
   }
   /*printf("nope\n");
   if (octants[0] == NULL) {
      printf("roll up in the club\n");
   } else {
      printf("yoyoyo\n");
   }*/
   
   
   if (octants[0]) {
      //printf("weird\n");
      if (octants[0]->transformed) {
         //printf("where is it\n");
         t = octants[0]->checkCollision(octants[0], glm::vec3(octants[0]->transform * startTransform), glm::mat3(thisObj->octants[0]->transform) * ray, time, &tempObj);
      } else {
         
         /*printf("ok...\n");
         
         pf = printf("Type octant? %d\n", octants[0]->type);
         printf("%d\n", pf);
         printf("BLAH octant? %d\n", octants[0]->blahblah);
         printf("AMBi octant? %f\n", octants[0]->ambient);
         
         
         octants[0]->type = 8;
         octants[0]->blahblah = 1;
         octants[0]->ambient = 4.0f;

         
         printf("OCTANT MEM: %p\n", octants[0]);
         printf("MORE OCTANT MEM: %p\n", thisObj + 1);
         printf("THIS COLL MEM: %p\n", thisObj->checkCollision);
         printf("OCTANT COLL MEM: %p\n", octants[0]->checkCollision);
         printf("OCT COLL MEM: %p\n", &(checkOctTreeCollision));
         printf("TRI COLL MEM: %p\n", &(checkTriCollision));
         
         
         for (int i = 0; i < 8; i++) {
            printf("INDEX %d: %d\n", i, indeces[i]);
         }
         
         
         //SETTING COLLISION FUNC PTR TO EQUIVALENT FUNCTION
         
         //octants[0]->checkCollision = &(checkOctTreeCollision2);
         
         
         printf("OCTANT COLL MEM: %p\n", octants[0]->checkCollision);
         printf("RANDOM\n");
         printf("FILLER\n");
         printf("STUFF\n");
         printf("TO\n");
         printf("SEE\n");
         printf("IF\n");
         printf("ITS\n");
         printf("BAD\n");
         printf("PARAM MEM AGAIN: %p\n", obj);
         
         
         // CALLING SECOND HERE
         // AFTER THIS IT WILL CRASH
         
         //octants[0] = (SceneObject*)0xb085e09a8;
         printf("NEW TYPE: %d\n", octants[0]->type);*/
         t = octants[0]->checkCollision(octants[0], start, ray, time, &tempObj);
      }
   }
   *object = tempObj;
   /*printf("t: %f\n", t);
   printf("Type? %d\n", thisObj->type);
   if (octants[1]) {
      printf("anything, really\n");
   } else {
      printf("pls\n");
   }
   printf("looking for something\n");*/
   
   int i = 0;
   
   // SAME AS ABOVE, BUT FOR THE OTHER 7 OCTANTS
   
   for (i = 1; i < 8; i++) {
      //printf("please\n");
      if (octants[i]) {
      //printf("yo\n");
         if (t >= 0.001) {
            //printf("hi\n");
            tempT = octants[i]->boundingBox.checkCollision(start, ray, time);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  tempT = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
               } else {
                  //printf("yo dawg\n");
                  if (octants[i]->type != 8) {
                     //printf("triangle starting\n");
                  }
                  
                  
                  tempT = octants[i]->checkCollision(octants[i], start, ray, time, &tempObj);
                  //printf("TTEMP : %f\n", tempT);
                  
                  /*printf("k\n");
                  if (octants[i]->type != 8) {
                     printf("triangle ending\n");
                  }*/
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  //printf("T : %f\n", t);
                  *object = tempObj;
               }
            }
         } else {
            //octants[i] = (SceneObject*)0xb085e09a8;
            t = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
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
}

float checkOctTreeCollision2(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
//printf("%f %f %f\n", start.x, start.y, start.z);
//printf("%f %f %f\n", ray.x, ray.y, ray.z);
printf("otree collision 2\n");
printf("PARAM MEM: %p\n", obj);
//return -1.0f;
   //printf("pls\n");
   glm::vec4 startTransform;
   float t, tempT;
   //int i;
   SceneObject* tempObj;
   t = tempT = -1.0f;
   OctTreeNode *thisObj = reinterpret_cast<OctTreeNode*>(obj);
   //printf("Wanted to make sure\n");
   SceneObject **octants = thisObj->octants;
   int *indeces = thisObj->indeces;
   //if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   //if (this == NULL) printf("Seriously what the fuck\n");
   printf("CURRENT MEM: %p\n", thisObj);
   int pf = printf("Type? %d\n", thisObj->type);
   printf("%d\n", pf);
   printf("blah? %d\n", thisObj->blahblah);
   printf("amb? %f\n", thisObj->ambient);
   printf("is it here?\n");
   if (thisObj->boundingBox.checkCollision(start, ray, time) < TOLERANCE) { printf("bb not hit\n"); return -1.0f; }
   printf("nope\n");
   if (octants[0] == NULL) {
      printf("roll up in the club\n");
   } else {
      printf("yoyoyo\n");//printf("like i got a fat...\n");
   }
   if (octants[0]) {
   if (octants[0]->transformed) {
      t = octants[0]->checkCollision(octants[0], glm::vec3(octants[0]->transform * startTransform), glm::mat3(thisObj->octants[0]->transform) * ray, time, &tempObj);
   } else {
      pf = printf("Type octant? %d\n", octants[0]->type);
      printf("%d\n", pf);
      printf("BLAH octant? %d\n", octants[0]->blahblah);
      printf("AMBi octant? %f\n", octants[0]->ambient);
      
      
      octants[0]->type = 8;
      octants[0]->blahblah = 1;
      octants[0]->ambient = 4.0f;

      printf("OCTANT MEM: %p\n", octants[0]);
      printf("MORE OCTANT MEM: %p\n", thisObj + 1);
      printf("THIS COLL MEM: %p\n", thisObj->checkCollision);
      printf("OCTANT COLL MEM: %p\n", octants[0]->checkCollision);
      printf("OCT COLL MEM: %p\n", &(checkOctTreeCollision));
      printf("TRI COLL MEM: %p\n", &(checkTriCollision));
      for (int i = 0; i < 8; i++) {
         printf("INDEX %d: %d\n", i, indeces[i]);
      }
      
      t = octants[0]->checkCollision(octants[0], start, ray, time, &tempObj);
   }
   }
   *object = tempObj;
   printf("t: %f\n", t);
   printf("Type? %d\n", thisObj->type);
   if (octants[1]) {
      printf("anything, really\n");
   } else {
      printf("pls\n");
   }
   printf("looking for something\n");
   
   int i = 0;
   for (i = 1; i < 8; i++) {
      printf("please\n");
      if (octants[i]) {
      printf("yo\n");
         if (t >= 0.001) {
            printf("hi\n");
            tempT = octants[i]->boundingBox.checkCollision(start, ray, time);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  tempT = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
               } else {
                  printf("yo dawg\n");
                  if (octants[i]->type != 8) {
                     printf("triangle starting\n");
                  }
                  tempT = octants[i]->checkCollision(octants[i], start, ray, time, &tempObj);
                  printf("k\n");
                  if (octants[i]->type != 8) {
                     printf("triangle ending\n");
                  }
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = tempObj;
               }
            }
         } else {
            t = octants[i]->checkCollision(octants[i], glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
            *object = tempObj;
         }
      } //else break();
      printf("sup fam\n");
   }
   printf("whats happening\n");
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;
}

float checkTriCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   //printf("Triangle Collision\n");
   glm::mat3 A, Ai;
   double detA, t, beta, gamma;
   Triangle *thisObj = reinterpret_cast<Triangle*>(obj);
   
   glm::vec3 a = thisObj->a;
   glm::vec3 b = thisObj->b;
   glm::vec3 c = thisObj->c;
   
   A = glm::mat3(a.x - b.x, a.x - c.x, ray.x,
                 a.y - b.y, a.y - c.y, ray.y,
                 a.z - b.z, a.z - c.z, ray.z);
   detA = glm::determinant(A);
   //std::cout << "making sure lol" << std::endl;
   //std::cout << detA << std::endl;
   //if (std::fabs(detA) > 0.0f) {
      //std::cout << "hi?" << std::endl;
      Ai = A;
      Ai[0][2] = a.x - start.x; Ai[1][2] = a.y - start.y; Ai[2][2] = a.z - start.z;
      t = glm::determinant(Ai) / detA;
      if (t > TOLERANCE) {
         //std::cout << "hiya" << std::endl;
         Ai = A;
         Ai[0][0] = a.x - start.x; Ai[1][0] = a.y - start.y; Ai[2][0] = a.z - start.z;
         gamma = glm::determinant(Ai) / detA;
         if (gamma >= 0.0f && gamma <= 1.0f) {
            //std::cout << "hello" << std::endl;
            Ai = A;
            Ai[0][1] = a.x - start.x; Ai[1][1] = a.y - start.y; Ai[2][1] = a.z - start.z;
            beta = glm::determinant(Ai) / detA;
            //std::cout << "Beta: " << beta << " Gamma: " << gamma << std::endl;
            if (beta >= 0.0f && beta + gamma <= 1.0f) {
               //std::cout << t << std::endl;
               //printf("obj type: %d\n", obj->type);
               *object = obj;
               return t;
            }
         }
      }
   //}
   //if (time < 3.5) obj->checkCollision(obj, start, ray, time + 1, object);
   return -1.0f;
}

float checkPlaneCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   float t = -1.0f;
   Plane *thisObj = reinterpret_cast<Plane*>(obj);
   //glm::vec3 origin = glm::vec3(0.0f, 0.0f, 0.0f);
   
   if (glm::dot(ray, thisObj->normal) != 0.0f) {
      t = glm::dot(thisObj->planePt - start, thisObj->normal) / glm::dot(ray, thisObj->normal);
   }
   
   *object = obj;
   return t;
}

float checkBiTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   glm::vec4 startTransform;
   float t, tLeft, tRight;
   SceneObject *lObj, *rObj;
   t = tLeft = tRight = -1.0f;
   BiTreeNode *thisObj = reinterpret_cast<BiTreeNode*>(obj);
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (thisObj->boundingBox.checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   //if (left) {
   if (thisObj->left->transformed) {
      tLeft = thisObj->left->checkCollision(thisObj->left, glm::vec3(thisObj->left->transform * startTransform), glm::mat3(thisObj->left->transform) * ray, time, &lObj);
   } else {
      tLeft = thisObj->left->checkCollision(thisObj->left, start, ray, time, &lObj);
   }
   if (thisObj->right) {
      if (tLeft >= TOLERANCE) {
         tRight = thisObj->right->boundingBox.checkCollision(start, ray, time);
         if (tRight >= TOLERANCE && tRight < tLeft) {
            if (thisObj->right->transformed) {
               tRight = thisObj->right->checkCollision(thisObj->right, glm::vec3(thisObj->right->transform * startTransform), glm::mat3(thisObj->right->transform) * ray, time, &rObj);
            } else {
               tRight = thisObj->right->checkCollision(thisObj->right, start, ray, time, &rObj);
            }
         } else {
            tRight = -1.0f;
         }
      } else {
         tRight = thisObj->right->checkCollision(thisObj->right, glm::vec3(thisObj->right->transform * startTransform), glm::mat3(thisObj->right->transform) * ray, time, &rObj);
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

float checkBoxCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   //std::cout << "Box Collision" << std::endl;
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

float checkQuadTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
//printf("qtree COLLISION\n");
   glm::vec4 startTransform;
   float t, tempT;
   SceneObject *obj1, *obj2, *obj3, *obj4;
   t = tempT = -1.0f;
   QuadTreeNode *thisObj = reinterpret_cast<QuadTreeNode*>(obj);
   SceneObject *q1 = thisObj->q1;
   SceneObject *q2 = thisObj->q2;
   SceneObject *q3 = thisObj->q3;
   SceneObject *q4 = thisObj->q4;
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (thisObj->boundingBox.checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   

   if (q1->transformed) {
      t = q1->checkCollision(q1, glm::vec3(q1->transform * startTransform), glm::mat3(q1->transform) * ray, time, &obj1);
   } else {
      t = q1->checkCollision(q1, start, ray, time, &obj1);
   }
   *object = obj1;
//printf("1\n");
   if (q2) {
      if (t >= TOLERANCE) {
         tempT = q2->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q2->transformed) {
               tempT = q2->checkCollision(q2, glm::vec3(q2->transform * startTransform), glm::mat3(q2->transform) * ray, time, &obj2);
            } else {
               tempT = q2->checkCollision(q2, start, ray, time, &obj2);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj2;
            }
         }
      } else {
         t = q2->checkCollision(q2, glm::vec3(q2->transform * startTransform), glm::mat3(q2->transform) * ray, time, &obj2);
         *object = obj2;
      }
   }
   //printf("2\n");
   if (q3) {
      if (t >= TOLERANCE) {
         tempT = q3->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q3->transformed) {
               tempT = q3->checkCollision(q3, glm::vec3(q3->transform * startTransform), glm::mat3(q3->transform) * ray, time, &obj3);
            } else {
               tempT = q3->checkCollision(q3, start, ray, time, &obj3);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj3;
            }
         }
      } else {
         t = q3->checkCollision(q3, glm::vec3(q3->transform * startTransform), glm::mat3(q3->transform) * ray, time, &obj3);
         *object = obj3;
      }
   }
   //printf("3\n");
   if (q4) {
      if (t >= TOLERANCE) {
         tempT = q4->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q4->transformed) {
               tempT = q4->checkCollision(q4, glm::vec3(q4->transform * startTransform), glm::mat3(q4->transform) * ray, time, &obj4);
            } else {
               tempT = q4->checkCollision(q4, start, ray, time, &obj4);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj4;
            }
         }
      } else {
         t = q4->checkCollision(q4, glm::vec3(q4->transform * startTransform), glm::mat3(q4->transform) * ray, time, &obj4);
         *object = obj4;
      }
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   //printf("4\n");
   return t;
}

float checkSphereCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   float t = -1.0f, t0, t1, innerRoot, A, B, C;
   Sphere *thisObj = reinterpret_cast<Sphere*>(obj);
   float radius = thisObj->radius;
   glm::vec3 position = thisObj->position;
   
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
   return t;
}

float checkGWCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   printf("GW Collision\n");
   *object = obj;
   return -1.0f;
}

float checkConeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object) {
   printf("Cone Collision\n");
   *object = obj;
   return -1.0f;
}
