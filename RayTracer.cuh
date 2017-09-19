/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __RAYTRACER_H__
#define __RAYTRACER_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>

#include "cuda_helper.h"
#include "Light.h"
#include "SceneObject.h"
#include "Image.h"
#include "Collision.h"
#include "structs.h"
#include "Photon.h"
#include "KDTreeNode.h"
//#include "deviceFuncsFile.cuh"

class RayTracer {
   public:
      RayTracer(std::vector<Light*>* l, std::vector<SceneObject*>* o);
      RayTracer(std::vector<Light*>* l, std::vector<SceneObject*>* o, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr);
      CUDA_CALLABLE RayTracer(SceneObject** o, int osize, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr);
      CUDA_CALLABLE RayTracer();
      CUDA_CALLABLE ~RayTracer();
      
      //CUDA_CALLABLE Collision* trace(glm::vec3 start, glm::vec3 ray, bool unit);
      CUDA_CALLABLE Collision* trace(glm::vec3 start, glm::vec3 ray, bool unit, int *shI, float *shF);
      //CUDA_CALLABLE Collision* trace(glm::vec3 start, glm::vec3 ray, int *shI, float *shF);
      CUDA_CALLABLE Collision* trace(glm::vec3 ray, int *shI, float *shF);
      CUDA_CALLABLE glm::vec3 findReflect(glm::vec3 ray, glm::vec3 normal, SceneObject* obj);
      CUDA_CALLABLE glm::vec3 findRefract(glm::vec3 ray, glm::vec3 normal, SceneObject* obj, float n1, float* n2, float* reflectScale, float* dropoff);
      
      Light** lights;
      int lightSize;
      SceneObject** objects;
      int objSize;
      
      KDTreeNode** cudaStack;
      int stackPartition;
      
      int numGPhotons;
      int numCPhotons;
      KDTreeNode* root;
      KDTreeNode* rootC1;
      
      //CUDA_CALLABLE volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF);
      CUDA_NO_INLINE CUDA_CALLABLE glm::vec3 calcRadiance(glm::vec3 start, volatile glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int threadNum, int depth, int *shI, float *shF) __attribute__ ((noinline));
      //__device__ __noinline__ glm::vec3 calcRadiance(glm::vec3 start, volatile glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int threadNum, int depth, int *shI, float *shF);
   private:
      //HELPERS FOR CR
      CUDA_NO_INLINE CUDA_CALLABLE volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF);
      //__device__ __noinline__ volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF);
      CUDA_NO_INLINE CUDA_CALLABLE glm::vec3 accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float* shF, int *shI);
      //__device__ __noinline__ glm::vec3 accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float* shF, int *shI);
      CUDA_NO_INLINE CUDA_CALLABLE void getNormal(SceneObject *obj, glm::vec3 iPt, float *shF);
      //__device__ __noinline__ void getNormal(SceneObject *obj, glm::vec3 iPt, float *shF);
};

#endif
