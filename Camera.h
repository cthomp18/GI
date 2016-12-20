/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"

#ifndef __CAMERA_H__
#define __CAMERA_H__

class Camera {
   public:
      Camera(glm::vec3 pos, glm::vec3 u, glm::vec3 r, glm::vec3 lA);
      Camera();
      ~Camera();
      
      void move(glm::vec3 pos);
      void change(glm::vec3 lA);
      glm::vec3 getPosition();
      glm::vec3 getLookAt();
      glm::vec3 getUp();
      glm::vec3 getRight();
      
   private:
      glm::vec3 position;
      glm::vec3 up;
      glm::vec3 right;
      glm::vec3 lookAt;
};

#endif
