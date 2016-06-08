/*
   Cody Thompson
   Photon Mapping
*/

#ifndef __KDNODE_H__
#define __KDNODE_H__

#include <Eigen/Dense>
#include <iostream>
#include "Photon.h"
#include "structs.h"
#include <vector>



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
      
      void locatePhotons(int i, Eigen::Vector3f pt, std::vector<Photon*> *locateHeap, float sampleDistSqrd, float *newRadSqrd, Eigen::Matrix3f mInv, int numPhotons);
};

#endif
