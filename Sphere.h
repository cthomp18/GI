/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __SPHERE_H__
#define __SPHERE_H__

#include "glm/glm.hpp"
#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "BoundingBox.h"
#include "cuda_helper.h"

class Sphere : public SceneObject {
   public:
      CUDA_CALLABLE Sphere(glm::vec3 pos, float rad);
      CUDA_CALLABLE Sphere();
      CUDA_CALLABLE virtual ~Sphere();
   
      glm::vec3 position;
      float radius;
      
      using SceneObject::checkCollision;
      using SceneObject::getNormal;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt, float time);
      CUDA_CALLABLE void constructBB();
      
   private:
   
};

#endif
