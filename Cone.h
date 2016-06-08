/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include <iostream>
#include "SceneObject.h"
#include "Collision.h"

#ifndef __CONE_H__
#define __CONE_H__

class Cone : public SceneObject {
   public:
      Cone(Eigen::Vector3f endPt1, float rad1, Eigen::Vector3f endPt2, float rad2);
      Cone();
      ~Cone();
   
      Eigen::Vector3f a;
      Eigen::Vector3f b;
      float radiusA;
      float radiusB;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
   private:
   
};

#endif
