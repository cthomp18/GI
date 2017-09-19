/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __DFF_H__
#define __DFF_H__

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

CUDA_NO_INLINE CUDA_CALLABLE volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF) __attribute__ ((noinline));
//__device__ __noinline__ volatile float * volatile getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF);
CUDA_NO_INLINE CUDA_CALLABLE glm::vec3 accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float* shF, int *shI) __attribute__ ((noinline));
//__device__ __noinline__ glm::vec3 accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float* shF, int *shI);
CUDA_NO_INLINE CUDA_CALLABLE __attribute__ ((noinline)) void __attribute__ ((noinline)) getNormal(SceneObject *obj, glm::vec3 iPt, float *shF) __attribute__ ((noinline));
//__device__ __noinline__ void getNormal(SceneObject *obj, glm::vec3 iPt, float *shF);
      
#endif
