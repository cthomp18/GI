/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __OctTreeNode_H__
#define __OctTreeNode_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>
#include <algorithm>
#include <math.h>

#include "cuda_helper.h"
#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Triangle.h"

class OctTreeNode : public SceneObject {
   public:
      OctTreeNode(std::vector<SceneObject*> objects, int n, int depth);
      CUDA_CALLABLE OctTreeNode(OctTreeNode* o);
      CUDA_CALLABLE OctTreeNode();
      CUDA_CALLABLE virtual ~OctTreeNode();
      
      SceneObject* octants[8];
      int indeces[8];

      using SceneObject::checkCollision;
      using SceneObject::getNormal;
      
      //int sortAxis;
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      //CUDA_CALLABLE float collision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      CUDA_CALLABLE float checkCollision2(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt);
      
      SceneObject* getObj();
      CUDA_CALLABLE void printObj();
      CUDA_CALLABLE int treeLength();
      CUDA_CALLABLE void toSerialArray(Triangle *objectArray, int *currentIndex);
      //CUDA_CALLABLE void toSerialArray(thrust::host_vector<SceneObject> *objectArray);
      //CUDA_CALLABLE void toOctTree(thrust::device_vector<SceneObject> *objectArray);
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      BoundingBox combineBB(std::vector<BoundingBox*> boxes);
};

#endif
