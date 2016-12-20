/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"

#ifndef __LIGHT_H__
#define __LIGHT_H__

class Light {
   public:
      Light(glm::vec3 pos, glm::vec3 col);
      Light();
      ~Light();
      
      void move(glm::vec3 pos);
      void changeColor(glm::vec3 col);
      glm::vec3 getPosition();
      glm::vec3 getColor();
      
   private:
      glm::vec3 position;
      glm::vec3 color;
};

#endif
