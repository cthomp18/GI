/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>

#ifndef __CAMERA_H__
#define __CAMERA_H__

class Camera {
   public:
      Camera(Eigen::Vector3f pos, Eigen::Vector3f u, Eigen::Vector3f r, Eigen::Vector3f lA);
      Camera();
      ~Camera();
      
      void move(Eigen::Vector3f pos);
      void change(Eigen::Vector3f lA);
      Eigen::Vector3f getPosition();
      Eigen::Vector3f getLookAt();
      Eigen::Vector3f getUp();
      Eigen::Vector3f getRight();
      
   private:
      Eigen::Vector3f position;
      Eigen::Vector3f up;
      Eigen::Vector3f right;
      Eigen::Vector3f lookAt;
};

#endif
