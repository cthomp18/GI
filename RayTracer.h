/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __RAYTRACER_H__
#define __RAYTRACER_H__

#include <Eigen/Dense>
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
      
      Collision* trace(Eigen::Vector3f start, Eigen::Vector3f ray, bool unit);
      Eigen::Vector3f findReflect(Eigen::Vector3f ray, Eigen::Vector3f normal, SceneObject* obj);
      Eigen::Vector3f findRefract(Eigen::Vector3f ray, Eigen::Vector3f normal, SceneObject* obj, float n1, float* n2, float* reflectScale, float* dropoff);
      
      std::vector<Light*> lights;
      std::vector<SceneObject*> objects;
      
      std::vector<Photon*> globalMap;
      std::vector<Photon*> causticMap;
      KDTreeNode* root;
      KDTreeNode* rootC1;
      
      color_t calcRadiance(Eigen::Vector3f start, Eigen::Vector3f iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int depth);
   private:
      
};

#endif
