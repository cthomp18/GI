/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
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
      Triangle(Eigen::Vector3f pt1, Eigen::Vector3f pt2, Eigen::Vector3f pt3);
      Triangle();
      ~Triangle();
   
      Eigen::Vector3f a;
      Eigen::Vector3f b;
      Eigen::Vector3f c;
      
      Eigen::Vector3f normal;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      void constructBB();
      
   private:
   
};

#endif
