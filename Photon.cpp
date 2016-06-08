/*
   Cody Thompson
   Photon Mapping
*/

#include "Photon.h"

Photon::Photon() { }
Photon::~Photon() { }

Photon::Photon(Eigen::Vector3f p, Eigen::Vector3f inc, Eigen::Vector3f i, int t) {
   pt = p;
   intensity = i;
   type = t;
   incidence = inc;
   sortAxis = -1;
}


bool operator<(const Photon p1, const Photon p2) { 
         if (p1.sortAxis == 0) {
            return p1.pt.x() < p2.pt.x();
         } else if (p1.sortAxis == 1) {
            return p1.pt.y() < p2.pt.y();
         } else if (p1.sortAxis == 2) {
            return p1.pt.z() < p2.pt.z();
         } else {
            return false; //fuck
         }
      }
