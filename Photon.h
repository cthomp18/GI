/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __PHOTON_H__
#define __PHOTON_H__

#include <Eigen/Dense>
#include <iostream>

class Photon {
   public:
      Eigen::Vector3f pt;
      Eigen::Vector3f intensity;
      int type; //0 Direct, 1 Indirect, 2 Shadow
      Eigen::Vector3f incidence;
      int sortAxis;
      
      Photon(Eigen::Vector3f p, Eigen::Vector3f inc, Eigen::Vector3f i, int t);
      Photon();
      ~Photon();
      
      friend bool operator<(Photon p1, Photon p2);
};


#endif
