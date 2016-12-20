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

class GerstnerWave : public SceneObject {
   public:
      std::vector<float> amplitude;
      std::vector<glm::vec3> direction;//(x,z)
      std::vector<float> wavelength;
      std::vector<float> speedPC;
      std::vector<float> frequency;
      std::vector<float> steepness;
      float yPos;//Level of water
      glm::vec3 lb;//Lower Left Bound (x,z)
      glm::vec3 ub;//Upper Right Bound (x,z)
      
      int waves;
      
      GerstnerWave(float a, float w, float s, glm::vec3 d, glm::vec3 lowerleft, glm::vec3 upperright, float yPosition);
      GerstnerWave();
      ~GerstnerWave();
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      void addWave(float a, float w, float s, glm::vec3 d);
      glm::vec3 getNormal(glm::vec3 iPt, float time);
      
      glm::vec3 getPoint(float x, float z, float time);
      
      void toPovFileMesh(char* fileName, float step, float time);
      void addTriangles(std::vector<SceneObject*> *objects, float step, float time);
};


#endif
