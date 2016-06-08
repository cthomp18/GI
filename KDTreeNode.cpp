/*
   Cody Thompson
   Photon Mapping
*/

#include "KDTreeNode.h"

using namespace std;

KDTreeNode::KDTreeNode(KDTreeNode *l, KDTreeNode *r, Photon *p, int a) {
   left = l;
   right = r;
   photon = p;
   axis = a;
}

KDTreeNode::KDTreeNode() { }

KDTreeNode::~KDTreeNode() { }

KDTreeNode* KDTreeNode::buildKDTree(std::vector<Photon*> pmap, int lastAxis) {
   //Build KDTree
   KDTreeNode *node = new KDTreeNode(NULL, NULL, NULL, -1);
   if (pmap.empty()) return node;
   
   std::vector<Photon*> subtreeL, subtreeR;
   Photon* p;
   int median, sortAxis;
   
   //Find Best Dimension
   float xMin, yMin, zMin, xMax, yMax, zMax;
   float dx = 0.0, dy = 0.0, dz = 0.0;
   if (lastAxis != 0) {
      xMin = findMin(pmap, 0);
      xMax = findMax(pmap, 0);
      dx = xMax - xMin;
   }
   if (lastAxis != 1) {
      yMin = findMin(pmap, 1);
      yMax = findMax(pmap, 1);
      dy = yMax - yMin;
   }
   if (lastAxis != 2) {
      zMin = findMin(pmap, 2);
      zMax = findMax(pmap, 2);
      dz = zMax - zMin;
   }

   if (dx >= dy && dx >= dz) {
      sortAxis = 0;
   } else if (dy >= dx && dy >= dz) {
      sortAxis = 1;
   } else {
      sortAxis = 2;
   }
   //cout << pmap.size() << endl;
   std::vector<Photon> tempPMap;
   tempPMap.clear();
   for (int i = 0; i < pmap.size(); i++) {
      pmap[i]->sortAxis = sortAxis;
      tempPMap.push_back(*pmap[i]);
   }
   //Sort by photons by value of best dimension
   //cout << "Here?" << endl;
   std::sort(tempPMap.begin(), tempPMap.end());
   //cout << "yeeeeeee" << endl;
   for (int i = 0; i < pmap.size(); i++) {
      p = new Photon(tempPMap[i].pt, tempPMap[i].incidence, tempPMap[i].intensity, tempPMap[i].type);
      pmap[i] = p;
   }
   //Get median point index
   median = (pmap.size()-1) / 2;
   //Set initial node properties
   //cout << "Boo" << endl;
   //cout << "median: " << median << endl;
   //cout << pmap[median]->pt.x() << " " << pmap[median]->pt.y() << " " << pmap[median]->pt.z() << endl;
   node = new KDTreeNode(NULL, NULL, pmap[median], sortAxis);
   //cout << "yee" << endl;
   
   //Put points in corresponding subtrees by dim value (and delete previous PMap)
   for (int i = 0; i < median; i++) {
      subtreeL.push_back(pmap[i]);
   }
   for (int i = median+1; i < pmap.size(); i++) {
      subtreeR.push_back(pmap[i]);
   }
   /*while(!pmap.empty()) {
		delete pmap.back();
		pmap.pop_back();
	}*/
	
   //Form node's children
   if (subtreeL.size() > 0) node->left = buildKDTree(subtreeL, sortAxis);
   else node->left = NULL;
   if (subtreeR.size() > 0) node->right = buildKDTree(subtreeR, sortAxis);
   else node->right = NULL;
   
   return node;
}

void KDTreeNode::locatePhotons(int i, Eigen::Vector3f pt, std::vector<Photon*> *locateHeap, float sampleDistSqrd, float *newRadSqrd, Eigen::Matrix3f mInv, int numPhotons) {
   Eigen::Vector3f rayBetween = pt - photon->pt;
   float distToPhotonSqrd = rayBetween.norm() * rayBetween.norm();
   
   if (2*i + 1 < numPhotons) {
      float distToPlane;
      //Find distance to plane (difference WRT splitting axis)
      if (axis == 0) distToPlane = pt.x() - photon->pt.x();
      else if (axis == 1) distToPlane = pt.y() - photon->pt.y();
      else if (axis == 2) distToPlane = pt.z() - photon->pt.z();
      
      //Point is on the 'left' of the plane
      if (distToPlane < 0.0) {
         //Search on left child
         if (left != NULL) left->locatePhotons(2*i, pt, locateHeap, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         //If distance to plane is less than the sample distance radius, then
         //sample sphere intersects plane, so check right child as well
         if (distToPlane*distToPlane < sampleDistSqrd) {
            if (right != NULL) right->locatePhotons(2*i + 1, pt, locateHeap, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         }
      } else {
         //Point on 'right' of plane
         //Search on right child
         if (right != NULL) right->locatePhotons(2*i + 1, pt, locateHeap, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         //If distance to plane is less than the sample distance radius, then
         //sample sphere intersects plane, so check left child as well
         if (distToPlane*distToPlane < sampleDistSqrd) {
            if (left != NULL) left->locatePhotons(2*i, pt, locateHeap, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         }
      }
   }
   //Check if photon is close enough to the point
   if (distToPhotonSqrd <= sampleDistSqrd && locateHeap->size() < CUTOFF_HEAP_SIZE) {
      Eigen::MatrixXf originLoc(1,3);
      originLoc << (photon->pt[0] - pt[0]), (photon->pt[1] - pt[1]), (photon->pt[2] - pt[2]);
      float rad = sqrt(sampleDistSqrd) * ELLIPSOID_SCALE;
      if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
         originLoc = originLoc * mInv;
      }
      if (((originLoc(0,0)*originLoc(0,0))/sampleDistSqrd) + ((originLoc(0,1)*originLoc(0,1))/sampleDistSqrd) + ((originLoc(0,2)*originLoc(0,2))/(rad*rad)) < 1.0) {
         locateHeap->push_back(photon);
         //cout << "INCIDENCE: " << -node->photon->incidence[0] << " " << -node->photon->incidence[1] << " " << -node->photon->incidence[2] << endl;
         //cout << "INTENSITY: " << node->photon->intensity[0] << " " << node->photon->intensity[1] << " " << node->photon->intensity[2] << endl;
         if (locateHeap->size() == CUTOFF_HEAP_SIZE) {
            *newRadSqrd = distToPhotonSqrd;
         }
      }
   }
}

int KDTreeNode::Treesize(KDTreeNode *node) {
   int num = 1;
   if (node->left != NULL) num += Treesize(node->left);
   if (node->right != NULL) num += Treesize(node->right);
   return num;
}
void KDTreeNode::printTree(KDTreeNode *node) {
   std::cout << "Pt: " << node->photon->pt << std::endl;
   std::cout << "Axis Split: " << node->axis << std::endl;
   if (node->left != NULL) {
      std::cout << "LEFT" << std::endl;
      printTree(node->left);
      std::cout << "BACK" << std::endl;
   }
   if (node->right != NULL) {
      std::cout << "RIGHT" << std::endl;
      printTree(node->right);
      std::cout << "BACK" << std::endl;
   }
}

float KDTreeNode::findMin(std::vector<Photon*> pmap, int axis) {
   float min;
   for (int i = 0; i < pmap.size(); i++) {
      if (i == 0 || pmap[i]->pt[axis] < min) {
         min = pmap[i]->pt[axis];
      }
   }
   return min;
}

float KDTreeNode::findMax(std::vector<Photon*> pmap, int axis) {
   float max;
   for (int i = 0; i < pmap.size(); i++) {
      if (i == 0 || pmap[i]->pt[axis] > max) {
         max = pmap[i]->pt[axis];
      }
   }
   
   /* CODY, THIS IS WRONG, YOU SHOULD KNOW THAT.
   YOU WANT TO RETURN MIN */
   return max;
}
