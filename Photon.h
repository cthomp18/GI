/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __PHOTON_H__
#define __PHOTON_H__

#include "glm/glm.hpp"
#include <iostream>

class Photon {
   public:
      glm::vec3 pt;
      glm::vec3 intensity;
      int type; //0 Direct, 1 Indirect, 2 Shadow
      glm::vec3 incidence;
      int sortAxis;
      
      Photon(glm::vec3 p, glm::vec3 inc, glm::vec3 i, int t);
      Photon();
      ~Photon();
      
      friend bool operator<(Photon p1, Photon p2);
};


#endif
