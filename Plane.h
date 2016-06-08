/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "SceneObject.h"
#include "Collision.h"

#ifndef __PLANE_H__
#define __PLANE_H__

class Plane : public SceneObject {
   public:
      Plane(Eigen::Vector3f n, float d);
      Plane();
      ~Plane();
      
      Eigen::Vector3f normal;
      float distance;
      Eigen::Vector3f planePt;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      
   private:
   
};

#endif
