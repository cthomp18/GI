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
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      glm::vec3 getNormal(glm::vec3 iPt);
      SceneObject* getObj();
      
      void printObj();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      Box* combineBB(Box* box1, Box* box2, Box* box3, Box* box4);
};

#endif
