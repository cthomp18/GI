/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "SceneObject.h"
#include "Collision.h"
#include "cuda_helper.h"

#ifndef __PLANE_H__
#define __PLANE_H__

class Plane : public SceneObject {
   public:
      CUDA_CALLABLE Plane(glm::vec3 n, float d);
      CUDA_CALLABLE Plane();
      CUDA_CALLABLE virtual ~Plane();
      
      glm::vec3 normal;
      float distance;
      glm::vec3 planePt;
      
      using SceneObject::checkCollision;
      using SceneObject::getNormal;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt, float time);
      
   private:
   
};

#endif
