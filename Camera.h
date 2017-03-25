/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "cuda_helper.h"

#ifndef __CAMERA_H__
#define __CAMERA_H__

class Camera {
   public:
      __host__ __device__ Camera(glm::vec3 pos, glm::vec3 u, glm::vec3 r, glm::vec3 lA);
      __host__ __device__ Camera();
      __host__ __device__ ~Camera();
      
      __host__ __device__ void move(glm::vec3 pos);
      __host__ __device__ void change(glm::vec3 lA);
      __host__ __device__ glm::vec3 getPosition();
      __host__ __device__ glm::vec3 getLookAt();
      __host__ __device__ glm::vec3 getUp();
      __host__ __device__ glm::vec3 getRight();
      
   private:
      glm::vec3 position;
      glm::vec3 up;
      glm::vec3 right;
      glm::vec3 lookAt;
};

#endif
