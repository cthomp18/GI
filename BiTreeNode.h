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

class BiTreeNode : public SceneObject {
   public:
      BiTreeNode(std::vector<SceneObject*> objects, int axis, int n);
      BiTreeNode();
      ~BiTreeNode();
      
      SceneObject *left;
      SceneObject *right;
      //int sortAxis;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      glm::vec3 getNormal(glm::vec3 iPt);
      SceneObject* getObj();
      
      void printTree();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      Box* combineBB(Box* box1, Box* box2);
};

#endif
