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

#include "SceneObject.h"
#include "Collision.h"
#include "structs.h"
#include "Box.h"

class OctTreeNode : public SceneObject {
   public:
      OctTreeNode(std::vector<SceneObject*> objects, int n, int depth);
      OctTreeNode();
      ~OctTreeNode();
      
      std::vector<SceneObject*> octants;

      //int sortAxis;
      
      float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      glm::vec3 getNormal(glm::vec3 iPt);
      SceneObject* getObj();
      
      void printObj();
      
   private:
      //bool sorter(const SceneObject* obj1, const SceneObject* obj2);
      Box* combineBB(std::vector<Box*> boxes);
};

#endif
