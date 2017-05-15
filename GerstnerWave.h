/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __GERSTNER_H__
#define __GERSTNER_H__

#include "glm/glm.hpp"
#include <iostream>
#include <fstream>
#include "Collision.h"
#include "SceneObject.h"
#include "structs.h"
#include "Triangle.h"
#include "cuda_helper.h"
#include "collisionFuncs.h"
#include "normalFuncs.h"

class GerstnerWave : public SceneObject {
   public:
      float *amplitude;
      glm::vec3 *direction;//(x,z)
      float *wavelength;
      float *speedPC;
      float *frequency;
      float *steepness;
      float yPos;//Level of water
      glm::vec3 lb;//Lower Left Bound (x,z)
      glm::vec3 ub;//Upper Right Bound (x,z)
      
      int waves;
      
      CUDA_CALLABLE GerstnerWave(float a, float w, float s, glm::vec3 d, glm::vec3 lowerleft, glm::vec3 upperright, float yPosition);
      CUDA_CALLABLE GerstnerWave();
      CUDA_CALLABLE virtual ~GerstnerWave();
      
      //using SceneObject::checkCollision;
      //using SceneObject::getNormal;
      
      //CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      void addWave(float a, float w, float s, glm::vec3 d);
      //CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt, float time);
      
      glm::vec3 getPoint(float x, float z, float time);
      
      void toPovFileMesh(char* fileName, float step, float time);
      void addTriangles(std::vector<SceneObject*> *objects, float step, float time);
};


#endif
