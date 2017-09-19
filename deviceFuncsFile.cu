#include "deviceFuncsFile.cuh"

__device__ __noinline__ volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF) {
   /*
   7: c
   8: s
   9: t
   */
   
   glm::mat3 matInv;
   glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   glm::vec3 eRay = glm::vec3(0.0, 0.0, 1.0);
   
   normal = glm::normalize(normal);
   if (fabs(ELLIPSOID_SCALE - 1.0) > TOLERANCE &&
       (fabs(fabs(normal[0]) - eRay[0]) > TOLERANCE ||
        fabs(fabs(normal[1]) - eRay[1]) > TOLERANCE ||
        fabs(fabs(normal[2]) - eRay[2]) > TOLERANCE)) {
        
      glm::vec3 crossP = glm::cross(eRay, normal);
      crossP = glm::normalize(crossP);
      
      shF[6] = glm::dot(eRay, normal); shF[7] = sin(acos(glm::dot(eRay, normal))); shF[8] = 1.0 - shF[6];
      glm::mat3 mat = glm::mat3(shF[8]*crossP.x*crossP.x + shF[6], shF[8]*crossP.x*crossP.y - crossP.z*shF[7], shF[8]*crossP.x*crossP.z + crossP.y*shF[7],
                                shF[8]*crossP.x*crossP.y + crossP.z*shF[7], shF[8]*crossP.y*crossP.y + shF[6], shF[8]*crossP.y*crossP.z - crossP.x*shF[7],
                                shF[8]*crossP.x*crossP.z - crossP.y*shF[7], shF[8]*crossP.y*crossP.z + crossP.x*shF[7], shF[8]*crossP.z*crossP.z + shF[6]);
      matInv = glm::inverse(mat);
   } else {
      matInv = glm::mat3(1.0f);
   }
   
   //volatile float* volatile mInv;// = 
   return glm::value_ptr(matInv);
}

__device__ __noinline__ glm::vec3 accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float *shF, int *shI) {
   glm::vec3 clr(0.0f, 0.0f, 0.0f);
   for (volatile int i = 0; i < shI[2]; i++) {
      //BRDF
      glm::vec3 normal = obj->getNormal(obj, iPt, shF);
      normal = glm::normalize(normal);
      float dotProd = glm::dot(-locateHeap[i]->incidence, normal);
      //if (shI[0] < causts) {
         //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      //} else {
         //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
         //clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      //}
   }
   return clr;
}

__device__ __noinline__ void getNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   normal = glm::normalize(normal);
   shF[3] = normal.x;
   shF[4] = normal.y;
   shF[5] = normal.z;
}
