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
#include "Collision.h"
#include "structs.h"
#include "BoundingBox.h"
#include "cuda_helper.h"

class QuadTreeNode : public SceneObject {
   public:
      QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth);
      QuadTreeNode();
      CUDA_CALLABLE virtual ~QuadTreeNode();
      
      SceneObject *q1;
      SceneObject *q2;
      SceneObject *q3;
      SceneObject *q4;
      //int sortAxis;
      
      using SceneObject::checkCollision;
      using SceneObject::getNormal;
      
      CUDA_CALLABLE float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      CUDA_CALLABLE glm::vec3 getNormal(glm::vec3 iPt);
      
      CUDA_CALLABLE void printObj();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      CUDA_CALLABLE BoundingBox combineBB(BoundingBox* box1, BoundingBox* box2, BoundingBox* box3, BoundingBox* box4);
};

#endif
