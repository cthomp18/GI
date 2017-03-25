/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __BiTreeNode_H__
#define __BiTreeNode_H__

#include <vector>
#include <iostream>
#include <algorithm>
#include <math.h>

#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Box.h"
#include "cuda_helper.h"
#include "glm/glm.hpp"

class BiTreeNode : public SceneObject {
   public:
      BiTreeNode(std::vector<SceneObject*> objects, int axis, int n);
      BiTreeNode();
      CUDA_CALLABLE virtual ~BiTreeNode();
      
      SceneObject *left;
      SceneObject *right;
      //int sortAxis;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt);
      
      void printTree();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      CUDA_CALLABLE BoundingBox combineBB(BoundingBox* box1, BoundingBox* box2);
};

#endif
