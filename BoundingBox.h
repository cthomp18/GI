/*
   Cody Thompson
   Thesis
   Winter 2017
*/

#ifndef __BBOX_H__
#define __BBOX_H__

#include <iostream>
#include <float.h>
#include "Collision.h"
#include "SceneObject.h"
#include "glm/glm.hpp"
#include "cuda_helper.h"

class BoundingBox {
   public:
      CUDA_CALLABLE BoundingBox(glm::vec3 cornerPt1, glm::vec3 cornerPt2);
      CUDA_CALLABLE BoundingBox();
      CUDA_CALLABLE ~BoundingBox();
   
      glm::vec3 minPt;
      glm::vec3 maxPt;
      glm::vec3 middle;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      CUDA_CALLABLE float checkCollision(glm::vec3 ray, float time, int *shI, float *shF);
      
   private:
   
};

#endif
