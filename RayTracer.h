/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __RAYTRACER_H__
#define __RAYTRACER_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>

#include "cuda_helper.h"
#include "Light.h"
#include "SceneObject.h"
#include "Image.h"
#include "Collision.h"
#include "structs.h"
#include "Photon.h"
#include "KDTreeNode.h"

class RayTracer {
   public:
      CUDA_CALLABLE RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o);
      CUDA_CALLABLE RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr);
      CUDA_CALLABLE RayTracer(SceneObject** o, int osize, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr);
      CUDA_CALLABLE RayTracer();
      CUDA_CALLABLE ~RayTracer();
      
      CUDA_CALLABLE Collision* trace(glm::vec3 start, glm::vec3 ray, bool unit);
      CUDA_CALLABLE glm::vec3 findReflect(glm::vec3 ray, glm::vec3 normal, SceneObject* obj);
      CUDA_CALLABLE glm::vec3 findRefract(glm::vec3 ray, glm::vec3 normal, SceneObject* obj, float n1, float* n2, float* reflectScale, float* dropoff);
      
      thrust::host_vector<Light*> lights;
      SceneObject** objects;
      int objSize;
      
      int numGPhotons;
      int numCPhotons;
      KDTreeNode* root;
      KDTreeNode* rootC1;
      
      CUDA_CALLABLE color_t calcRadiance(glm::vec3 start, glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int depth);
   private:
      
};

#endif
