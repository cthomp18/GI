/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>

#ifndef __LIGHT_H__
#define __LIGHT_H__

class Light {
   public:
      Light(Eigen::Vector3f pos, Eigen::Vector3f col);
      Light();
      ~Light();
      
      void move(Eigen::Vector3f pos);
      void changeColor(Eigen::Vector3f col);
      Eigen::Vector3f getPosition();
      Eigen::Vector3f getColor();
      
   private:
      Eigen::Vector3f position;
      Eigen::Vector3f color;
};

#endif
