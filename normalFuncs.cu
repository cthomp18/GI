#include "normalFuncs.h"

glm::vec3 getOctTreeNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   OctTreeNode *thisObj = reinterpret_cast<OctTreeNode*>(obj);
   
   printf("the fuck\n");
   return glm::vec3(0.0f, 0.0f, 0.0f);
}

// glm::vec3 getOctTreeNormal2(SceneObject *thisObj, glm::vec3 iPt, float time);

glm::vec3 getTriNormal(SceneObject *obj, glm::vec3 iPt, float time) {
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
   //printf("sup dawg\n");
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
}

glm::vec3 getSphereNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   Sphere *thisObj = reinterpret_cast<Sphere*>(obj);
   
   return (iPt - thisObj->position) / thisObj->radius;
}

glm::vec3 getPlaneNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   Plane *thisObj = reinterpret_cast<Plane*>(obj);
   
   return thisObj->normal;
}

glm::vec3 getBiTreeNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   BiTreeNode *thisObj = reinterpret_cast<BiTreeNode*>(obj);
   
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return iPt;
}

glm::vec3 getBoxNormal(SceneObject *obj, glm::vec3 iPt, float time) {
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

glm::vec3 getGWNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   GerstnerWave *thisObj = reinterpret_cast<GerstnerWave*>(obj);
   
   glm::vec3 normal = glm::vec3(0.0f, 1.0f, 0.0f);
   float wa, wdpt, coswa;
   
   int waves = thisObj->waves;
   float *frequency = thisObj->frequency;
   float *amplitude = thisObj->amplitude;
   glm::vec3 *direction = thisObj->direction;
   float *speedPC = thisObj->speedPC;
   float *steepness = thisObj->steepness;
   
   for (int i = 0; i < waves; i++) {
      wa = frequency[i] * amplitude[i];
      wdpt = glm::dot(frequency[i] * glm::vec3(direction[i].x, 0.0f, direction[i].z), iPt) + (time * speedPC[i]);
      coswa = wa * cos(wdpt);
      normal -= glm::vec3(direction[i].x * coswa, (steepness[i] * wa * sin(wdpt)), direction[i].z * coswa);
   }
   normal = glm::normalize(normal);
   
   return normal;
}

glm::vec3 getConeNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   Cone *thisObj = reinterpret_cast<Cone*>(obj);
   
   return glm::vec3(-1.0f, -1.0f, -1.0f);
}

glm::vec3 getQuadTreeNormal(SceneObject *obj, glm::vec3 iPt, float time) {
   QuadTreeNode *thisObj = reinterpret_cast<QuadTreeNode*>(obj);
   
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return iPt;
}
