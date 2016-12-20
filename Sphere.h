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
#include "Box.h"

class Sphere : public SceneObject {
   public:
      Sphere(glm::vec3 pos, float rad);
      Sphere();
      ~Sphere();
   
      glm::vec3 position;
      float radius;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      glm::vec3 getNormal(glm::vec3 iPt, float time);
      void constructBB();
      
   private:
   
};

#endif
