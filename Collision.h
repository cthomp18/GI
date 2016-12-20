/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __COLLISION_H__
#define __COLLISION_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>
#include "structs.h"
class SceneObject;

class Collision {
   public:
      Collision(float t, SceneObject* s);
      Collision();
      ~Collision();
      
      void detectRayCollision(glm::vec3 start, glm::vec3 ray, std::vector<SceneObject*> objects, int omitInd, bool unit);
      
      float time;
      SceneObject* object;
      
   private:
   
};

#endif
