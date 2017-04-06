/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include <iostream>
#include "SceneObject.h"
#include "Collision.h"
#include "cuda_helper.h"

#ifndef __CONE_H__
#define __CONE_H__

class Cone : public SceneObject {
   public:
      Cone(glm::vec3 endPt1, float rad1, glm::vec3 endPt2, float rad2);
      Cone();
      CUDA_CALLABLE virtual ~Cone();
   
      glm::vec3 a;
      glm::vec3 b;
      float radiusA;
      float radiusB;
      
      using SceneObject::checkCollision;
      using SceneObject::getNormal;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt, float time);
   private:
   
};

#endif
