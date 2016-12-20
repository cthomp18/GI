/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __PHOTONMAP_H__
#define __PHOTONMAP_H__

#include "glm/glm.hpp"
#include <iostream>
#include <vector>

#include "Photon.h"
#include "structs.h"
#include "SceneObject.h"
#include "Light.h"
#include "Sphere.h"
#include "RayTracer.h"

class PhotonMapper {
   public:
      PhotonMapper();
      ~PhotonMapper();
      PhotonMapper(std::vector<Light*> l, std::vector<SceneObject*> o);

      std::vector<Photon*> globalPhotons;
      std::vector<Photon*> causticPhotons;
      int numPhotons;
      std::vector<Light*> lights;
      std::vector<SceneObject*> objects;
      
      void buildGlobalMap();
      void buildCausticMap();
};

#endif
