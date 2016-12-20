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

class Box : public SceneObject {
   public:
      Box(glm::vec3 cornerPt1, glm::vec3 cornerPt2);
      Box();
      ~Box();
   
      glm::vec3 minPt;
      glm::vec3 maxPt;
      glm::vec3 middle;
      bool unit;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      glm::vec3 getNormal(glm::vec3 iPt);
      void constructBB();

   private:
   
};

#endif
