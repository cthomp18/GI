/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __RAYTRACER_H__
#define __RAYTRACER_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>

#include "Light.h"
#include "SceneObject.h"
#include "Image.h"
#include "Collision.h"
#include "structs.h"
#include "Photon.h"
#include "KDTreeNode.h"

class RayTracer {
   public:
      RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o);
      RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o, std::vector<Photon*> gM, std::vector<Photon*> cM, KDTreeNode* gr, KDTreeNode* cr);
      RayTracer();
      ~RayTracer();
      
      Collision* trace(glm::vec3 start, glm::vec3 ray, bool unit);
      glm::vec3 findReflect(glm::vec3 ray, glm::vec3 normal, SceneObject* obj);
      glm::vec3 findRefract(glm::vec3 ray, glm::vec3 normal, SceneObject* obj, float n1, float* n2, float* reflectScale, float* dropoff);
      
      std::vector<Light*> lights;
      std::vector<SceneObject*> objects;
      
      std::vector<Photon*> globalMap;
      std::vector<Photon*> causticMap;
      KDTreeNode* root;
      KDTreeNode* rootC1;
      
      color_t calcRadiance(glm::vec3 start, glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int depth);
   private:
      
};

#endif
