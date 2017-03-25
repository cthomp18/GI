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
#include "cuda_helper.h"


class KDTreeNode {
   public: 
      KDTreeNode *left;
      KDTreeNode *right;
      Photon *photon;
      int axis; //This is the axis that its children are separated on (x=0y=1z=2)
      
      CUDA_CALLABLE KDTreeNode(KDTreeNode *l, KDTreeNode *r, Photon *p, int a);
      CUDA_CALLABLE KDTreeNode();
      CUDA_CALLABLE ~KDTreeNode();
      
      CUDA_CALLABLE KDTreeNode* buildKDTree(std::vector<Photon*> pmap, int lastAxis);
      CUDA_CALLABLE int Treesize(KDTreeNode *node);
      CUDA_CALLABLE void printTree(KDTreeNode *node);
      CUDA_CALLABLE float findMin(std::vector<Photon*> pmap, int axis);
      CUDA_CALLABLE float findMax(std::vector<Photon*> pmap, int axis);
      
      CUDA_CALLABLE void locatePhotons(int i, glm::vec3 pt, std::vector<Photon*> *locateHeap, float sampleDistSqrd, float *newRadSqrd, glm::mat3 mInv, int numPhotons);
};

#endif
