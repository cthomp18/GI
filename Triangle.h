/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include <iostream>
#include "SceneObject.h"
#include "Collision.h"
#include "Box.h"
#include <float.h>
#include <math.h>

#ifndef __TRIANGLE_H__
#define __TRIANGLE_H__

class Triangle : public SceneObject {
   public:
      Triangle(glm::vec3 pt1, glm::vec3 pt2, glm::vec3 pt3);
      Triangle(glm::vec3 pt1, glm::vec3 pt2, glm::vec3 pt3, bool smoothCheck);
      Triangle();
      ~Triangle();
   
      glm::vec3 a;
      glm::vec3 b;
      glm::vec3 c;
      
      glm::vec3 normal;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      glm::vec3 getNormal(glm::vec3 iPt, float time);
      void constructBB();
      void printObj();
      
      // Wave or 3d object settings
      bool smooth;
      glm::vec3 aNor;
      glm::vec3 bNor;
      glm::vec3 cNor;
      // Barycentric Precomputations
      float dotAB;
      float dotAC;
      float dotABC;
      float multiplier;
      
   private:
   
};

#endif
