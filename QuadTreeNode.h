/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __QuadTreeNode_H__
#define __QuadTreeNode_H__

#include "glm/glm.hpp"
#include <vector>
#include <iostream>
#include <algorithm>
#include <math.h>

#include "SceneObject.h"
#include "Triangle.h"
#include "Collision.h"
#include "structs.h"
#include "BoundingBox.h"
#include "cuda_helper.h"
#include "Triangle.h"
#include "collisionFuncs.h"
#include "normalFuncs.h"

class Triangle;

class QuadTreeNode : public SceneObject {
   public:
      QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth);
      QuadTreeNode();
      CUDA_CALLABLE virtual ~QuadTreeNode();
      
      SceneObject *quadrants[4];
      int indeces[4];
      
      CUDA_CALLABLE void printObj();
      CUDA_CALLABLE int treeLength();
      CUDA_CALLABLE void toSerialArray(Triangle *objectArray, int *currentIndex);
      
   private:
      BoundingBox combineBB(std::vector<BoundingBox*> boxes);
};

#endif
