/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __BOX_H__
#define __BOX_H__

#include <iostream>
#include <float.h>
#include "Collision.h"
#include "SceneObject.h"
#include "glm/glm.hpp"
#include "BoundingBox.h"
#include "cuda_helper.h"

class Box : public SceneObject {
   public:
      CUDA_CALLABLE Box(glm::vec3 cornerPt1, glm::vec3 cornerPt2);
      CUDA_CALLABLE Box();
      CUDA_CALLABLE virtual ~Box();
   
      glm::vec3 minPt;
      glm::vec3 maxPt;
      glm::vec3 middle;
      bool unit;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt);
      CUDA_CALLABLE void constructBB();

   private:
   
};

#endif
