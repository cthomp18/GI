/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __BOX_H__
#define __BOX_H__

#include <Eigen/Dense>
#include <iostream>
#include <float.h>
#include "Collision.h"
#include "SceneObject.h"

class Box : public SceneObject {
   public:
      Box(Eigen::Vector3f cornerPt1, Eigen::Vector3f cornerPt2);
      Box();
      ~Box();
   
      Eigen::Vector3f minPt;
      Eigen::Vector3f maxPt;
      Eigen::Vector3f middle;
      bool unit;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt);
      void constructBB();

   private:
   
};

#endif
