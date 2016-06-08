/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __SPHERE_H__
#define __SPHERE_H__

#include <Eigen/Dense>
#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Box.h"

class Sphere : public SceneObject {
   public:
      Sphere(Eigen::Vector3f pos, float rad);
      Sphere();
      ~Sphere();
   
      Eigen::Vector3f position;
      float radius;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      void constructBB();
      
   private:
   
};

#endif
