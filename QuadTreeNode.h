/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __QuadTreeNode_H__
#define __QuadTreeNode_H__

#include <Eigen/Dense>
#include <vector>
#include <iostream>
#include <algorithm>
#include <math.h>

#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Box.h"

class QuadTreeNode : public SceneObject {
   public:
      QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth);
      QuadTreeNode();
      ~QuadTreeNode();
      
      SceneObject *q1;
      SceneObject *q2;
      SceneObject *q3;
      SceneObject *q4;
      //int sortAxis;
      
      float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object);
      Eigen::Vector3f getNormal(Eigen::Vector3f iPt);
      SceneObject* getObj();
      
      void printObj();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      Box* combineBB(Box* box1, Box* box2, Box* box3, Box* box4);
};

#endif
