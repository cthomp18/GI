#include "normalFuncs.h"

glm::vec3 getOctTreeNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   OctTreeNode *thisObj = reinterpret_cast<OctTreeNode*>(obj);
   
   printf("the fuck\n");
   return glm::vec3(0.0f, 0.0f, 0.0f);
}

// glm::vec3 getOctTreeNormal2(SceneObject *thisObj, glm::vec3 iPt, float time);

//See detailed function below
glm::vec3 getTriNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   //F1: intersect point x
   //F2: intersect point y
   //F3: intersect point z
   //F4: alpha
   //F5: beta
   //F6: gamma
   //F7: dot product ABP
   //F8: dot product ACP
   
   Triangle *thisObj = reinterpret_cast<Triangle*>(obj);
   
   shF[1] = iPt.x;
   shF[2] = iPt.y;
   shF[3] = iPt.z;
   
   
   glm::vec3 normalConstructor = thisObj->normal;

   shF[7] = (thisObj->b.x - thisObj->a.x) * (shF[1] - thisObj->a.x);
   shF[7] += (thisObj->b.y - thisObj->a.y) * (shF[2] - thisObj->a.y);
   shF[7] += (thisObj->b.z - thisObj->a.z) * (shF[3] - thisObj->a.z);
   shF[8] = (thisObj->c.x - thisObj->a.x) * (shF[1] - thisObj->a.x);
   shF[8] += (thisObj->c.y - thisObj->a.y) * (shF[2] - thisObj->a.y);
   shF[8] += (thisObj->c.z - thisObj->a.z) * (shF[3] - thisObj->a.z);

   shF[4] = ((thisObj->dotAC * shF[7]) - (thisObj->dotABC * shF[8])) * thisObj->multiplier;
   shF[5] = ((thisObj->dotAB * shF[8]) - (thisObj->dotABC * shF[7])) * thisObj->multiplier;
   
   shF[6] = (1.0f - shF[4]) - shF[5];

   normalConstructor = thisObj->bNor * shF[4];
   normalConstructor += thisObj->cNor * shF[5];
   normalConstructor += thisObj->aNor * shF[6];
   
   normalConstructor = glm::normalize(normalConstructor);
   
   return normalConstructor;
}

/*glm::vec3 getTriNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   Triangle *thisObj = reinterpret_cast<Triangle*>(obj);
   
   float alpha, beta, gamma;
   float multiplier = thisObj->multiplier;
   float dotAC = thisObj->dotAC;
   float dotAB = thisObj->dotAB;
   float dotABC = thisObj->dotABC;
   glm::vec3 a = thisObj->a;
   glm::vec3 b = thisObj->b;
   glm::vec3 c = thisObj->c;
   glm::vec3 aNor = thisObj->aNor;
   glm::vec3 bNor = thisObj->bNor;
   glm::vec3 cNor = thisObj->cNor;
   
   glm::vec3 normalConstructor = thisObj->normal;
   if (thisObj->smooth) {
      float dotABP = glm::dot(b - a, iPt - a), dotACP = glm::dot(c - a, iPt - a);
      alpha = ((dotAC * dotABP) - (dotABC * dotACP)) * multiplier;
      beta = ((dotAB * dotACP) - (dotABC * dotABP)) * multiplier;
      gamma = (1.0f - alpha) - beta;
      
      normalConstructor = bNor * alpha;
      normalConstructor += cNor * beta;
      normalConstructor += aNor * gamma;
      normalConstructor = glm::normalize(normalConstructor);
   }
   
   return normalConstructor;
}*/

glm::vec3 getSphereNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   Sphere *thisObj = reinterpret_cast<Sphere*>(obj);
   glm::vec3 returnvec = (iPt - thisObj->position) / thisObj->radius;
   return returnvec;
}

glm::vec3 getPlaneNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   Plane *thisObj = reinterpret_cast<Plane*>(obj);
   
   return thisObj->normal;
}

glm::vec3 getBiTreeNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   BiTreeNode *thisObj = reinterpret_cast<BiTreeNode*>(obj);
   
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return iPt;
}

glm::vec3 getBoxNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   Box *thisObj = reinterpret_cast<Box*>(obj);
   
   glm::vec3 normal = glm::vec3(0.0f, 0.0f, 0.0f);
   glm::vec3 minPt = thisObj->minPt;
   glm::vec3 maxPt = thisObj->maxPt;
   
   for (int i = 0; i < 3; i++) {
      if (fabs(iPt[i] - minPt[i]) < TOLERANCE) {
         normal[i] = -1.0f;
      } else if (fabs(iPt[i] - maxPt[i]) < TOLERANCE) {
         normal[i] = 1.0f;
      }
   }
   
   return normal;
}

//See better function below
//Currently this is at 34 regs, doesn't seem to be any fucking way to make it less (i already tried removing iPt as a parameter)
glm::vec3 getGWNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   //start:
   //F0: time
   //middle:
   //F2: temp vect x
   //F3: temp vect z
   //F4: intersect point x
   //F5: intersect point z
   //F6: wa
   //F7: wdpt
   //F8: coswa
   
   volatile GerstnerWave *thisObj = reinterpret_cast<volatile GerstnerWave*>(obj);
   glm::vec3 normal = glm::vec3(0.0f, 1.0f, 0.0f);

   shF[4] = iPt.x;
   shF[5] = iPt.z;
   
   volatile int i = 0;
   for ( ; i < thisObj->waves; i++) {
      //if (1) {
         //volatile float f1 = thisObj->frequency[i];
         //volatile float f2 = thisObj->amplitude[i];
         shF[6] = thisObj->frequency[i] * thisObj->amplitude[i];
         //shF[6] = f1 * f2;
         shF[2] = thisObj->direction[i].x * thisObj->frequency[i];
         //shF[2] = thisObj->direction[i].x * f1;
         shF[3] = thisObj->direction[i].z * thisObj->frequency[i];
         //shF[3] = thisObj->direction[i].z * f1;
         shF[7] = shF[2] * shF[4] + shF[3] * shF[5];
         shF[7] = shF[7] + shF[0] * thisObj->speedPC[i];
      //}
      //if (1) {
         //f1 = thisObj->speedPC[i];
         
         //volatile float f1 = cos(shF[7]);
         shF[8] = shF[6] * cos(shF[7]);
      //}
      //normal -= glm::vec3(thisObj->direction[i].x * shF[8], (thisObj->steepness[i] * shF[6] * sin(shF[7])), thisObj->direction[i].z * shF[8]);
      normal.x -= thisObj->direction[i].x * shF[8];
      normal.y -= thisObj->steepness[i] * shF[6] * sin(shF[7]);
      normal.z -= thisObj->direction[i].z * shF[8];
   }
   
   normal = glm::normalize(normal);
   
   return normal;
}

/*glm::vec3 getGWNormal(SceneObject *obj, glm::vec3 iPt, int *shI, float *shF) {
   GerstnerWave *thisObj = reinterpret_cast<GerstnerWave*>(obj);
   
   glm::vec3 normal = glm::vec3(0.0f, 1.0f, 0.0f);
   float wa, wdpt, coswa;
   
   int waves = thisObj->waves;
   
   for (int i = 0; i < waves; i++) {
      wa = thisObj->frequency[i] * thisObj->amplitude[i];
      wdpt = glm::dot(thisObj->frequency[i] * glm::vec3(thisObj->direction[i].x, 0.0f, thisObj->direction[i].z), iPt) + (shF[0] * thisObj->speedPC[i]);
      coswa = wa * cos(wdpt);
      normal -= glm::vec3(thisObj->direction[i].x * coswa, (thisObj->steepness[i] * wa * sin(wdpt)), thisObj->direction[i].z * coswa);
   }
   normal = glm::normalize(normal);
   
   return normal;
}*/

glm::vec3 getConeNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   Cone *thisObj = reinterpret_cast<Cone*>(obj);
   
   return glm::vec3(-1.0f, -1.0f, -1.0f);
}

glm::vec3 getQuadTreeNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   QuadTreeNode *thisObj = reinterpret_cast<QuadTreeNode*>(obj);
   
   return iPt;
}
