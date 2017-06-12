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

bool compPhotons(Photon* p1, Photon* p2);

class KDTreeNode {
   public: 
      KDTreeNode *left;
      KDTreeNode *right;
      Photon *photon;
      int axis; //This is the axis that its children are separated on (x=0y=1z=2)
      
      int leftInd;
      int rightInd;
      
      CUDA_CALLABLE KDTreeNode(KDTreeNode *l, KDTreeNode *r, Photon *p, int a);
      CUDA_CALLABLE KDTreeNode();
      CUDA_CALLABLE ~KDTreeNode();
      
      KDTreeNode* buildKDTree(std::vector<Photon*> pmap, int lastAxis);
      CUDA_CALLABLE int Treesize();
      CUDA_CALLABLE void printTree(KDTreeNode *node);
      float findMin(std::vector<Photon*> pmap, int axis);
      float findMax(std::vector<Photon*> pmap, int axis);
      
      CUDA_CALLABLE void locatePhotons(glm::vec3 pt, Photon** locateHeap, int *heapSize, float sampleDistSqrd, float *newRadSqrd, glm::mat3 mInv, int numPhotons, KDTreeNode **stack);
      //CUDA_CALLABLE void locatePhotons(glm::vec3 pt, int ts, Photon** locateHeap, float sampleDistSqrd, float *newRadSqrd, int numPhotons, float *sh);
      
      CUDA_CALLABLE void toSerialArray(Photon *objectArray, int *currentIndex);
};

#endif
