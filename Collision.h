/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __COLLISION_H__
#define __COLLISION_H__

#include "cuda_helper.h"
#include "glm/glm.hpp"
#include <vector>
#include <iostream>
#include "structs.h"
class SceneObject;

class Collision {
   public:
      CUDA_CALLABLE Collision(float t, SceneObject* s);
      CUDA_CALLABLE Collision();
      CUDA_CALLABLE ~Collision();
      
      void detectRayCollision(glm::vec3 start, glm::vec3 ray, thrust::host_vector<SceneObject*> objects, uint omitInd, bool unit);
      CUDA_CALLABLE void detectRayCollision(glm::vec3 start, glm::vec3 ray, SceneObject** objects, int objSize, int omitInd, bool unit);
      
      float time;
      SceneObject* object;
      
   private:
   
};

#endif
