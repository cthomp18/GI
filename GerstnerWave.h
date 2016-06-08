/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __GERSTNER_H__
#define __GERSTNER_H__

#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include "Collision.h"
#include "SceneObject.h"
#include "structs.h"

class GerstnerWave : public SceneObject {
   public:
      std::vector<float> amplitude;
      std::vector<Eigen::Vector2f> direction;//(x,z)
      std::vector<float> wavelength;
      std::vector<float> speedPC;
      std::vector<float> frequency;
      std::vector<float> steepness;
      float yPos;//Level of water
      Eigen::Vector2f lb;//Lower Left Bound (x,z)
      Eigen::Vector2f ub;//Upper Right Bound (x,z)
      
      int waves;
      
      GerstnerWave(float a, float w, float s, Eigen::Vector2f d, Eigen::Vector2f lowerleft, Eigen::Vector2f upperright, float yPosition);
      GerstnerWave();
      ~GerstnerWave();
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      void addWave(float a, float w, float s, Eigen::Vector2f d);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      
      Eigen::Vector3f getPoint(float x, float z, float time);
      
      void toPovFileMesh(char* fileName, float step, float time);
};


#endif
