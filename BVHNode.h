/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __BVHNODE_H__
#define __BVHNODE_H__

#include <Eigen/Dense>
#include <vector>
#include <iostream>
#include <algorithm>
#include <math.h>

#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Box.h"

class BVHNode : public SceneObject {
   public:
      BVHNode(std::vector<SceneObject*> objects, int axis, int n);
      BVHNode();
      ~BVHNode();
      
      SceneObject *left;
      SceneObject *right;
      //int sortAxis;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt);
      SceneObject* getObj();
      
      void printTree();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      Box* combineBB(Box* box1, Box* box2);
};

#endif
