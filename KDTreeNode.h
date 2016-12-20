/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __KDNODE_H__
#define __KDNODE_H__

#include "glm/glm.hpp"
#include "glm/gtx/string_cast.hpp"
#include <iostream>
#include "Photon.h"
#include "structs.h"
#include <vector>
#include <algorithm>



class KDTreeNode {
   public: 
      KDTreeNode *left;
      KDTreeNode *right;
      Photon *photon;
      int axis; //This is the axis that its children are separated on (x=0y=1z=2)
      
      KDTreeNode(KDTreeNode *l, KDTreeNode *r, Photon *p, int a);
      KDTreeNode();
      ~KDTreeNode();
      
      KDTreeNode* buildKDTree(std::vector<Photon*> pmap, int lastAxis);
      int Treesize(KDTreeNode *node);
      void printTree(KDTreeNode *node);
      float findMin(std::vector<Photon*> pmap, int axis);
      float findMax(std::vector<Photon*> pmap, int axis);
      
      void locatePhotons(int i, glm::vec3 pt, std::vector<Photon*> *locateHeap, float sampleDistSqrd, float *newRadSqrd, glm::mat3 mInv, int numPhotons);
};

#endif
