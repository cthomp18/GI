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
#include "Triangle.h"

class GerstnerWave : public SceneObject {
   public:
      std::vector<float> amplitude;
      std::vector<Eigen::Vector3f> direction;//(x,z)
      std::vector<float> wavelength;
      std::vector<float> speedPC;
      std::vector<float> frequency;
      std::vector<float> steepness;
      float yPos;//Level of water
      Eigen::Vector3f lb;//Lower Left Bound (x,z)
      Eigen::Vector3f ub;//Upper Right Bound (x,z)
      
      int waves;
      
      GerstnerWave(float a, float w, float s, Eigen::Vector3f d, Eigen::Vector3f lowerleft, Eigen::Vector3f upperright, float yPosition);
      GerstnerWave();
      ~GerstnerWave();
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      void addWave(float a, float w, float s, Eigen::Vector3f d);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      
      Eigen::Vector3f getPoint(float x, float z, float time);
      
      void toPovFileMesh(char* fileName, float step, float time);
      void addTriangles(std::vector<SceneObject*> *objects, float step, float time);
};


#endif
