/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "SceneObject.h"
#include "Collision.h"

#ifndef __PLANE_H__
#define __PLANE_H__

class Plane : public SceneObject {
   public:
      Plane(glm::vec3 n, float d);
      Plane();
      ~Plane();
      
      glm::vec3 normal;
      float distance;
      glm::vec3 planePt;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      glm::vec3 getNormal(glm::vec3 iPt, float time);
      
   private:
   
};

#endif
