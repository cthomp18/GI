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
   
   leftInd = rightInd = -1;
}

KDTreeNode::KDTreeNode() {
   left = NULL;
   right = NULL;
   photon = NULL;
   axis = -1;
}

KDTreeNode::~KDTreeNode() {
   if (left) delete left;
   if (right) delete right;
   if (photon) delete photon;
}

KDTreeNode* KDTreeNode::buildKDTree(std::vector<Photon*> pmap, int lastAxis) {
   //Build KDTree
   KDTreeNode *node;// = new KDTreeNode(NULL, NULL, NULL, -1);
   if (pmap.empty()) return new KDTreeNode(NULL, NULL, NULL, -1);;

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
   std::vector<Photon*> tempPMap;
   tempPMap.clear();
   for (uint i = 0; i < pmap.size(); i++) {
      pmap[i]->sortAxis = sortAxis;
      tempPMap.push_back(pmap[i]);
   }
   //Sort by photons by value of best dimension
   //cout << "Here?" << endl;
   std::sort(tempPMap.begin(), tempPMap.end(), compPhotons);
   //cout << "yeeeeeee" << endl;
   for (uint i = 0; i < pmap.size(); i++) {
      //p = new Photon(tempPMap[i].pt, tempPMap[i].incidence, tempPMap[i].intensity, tempPMap[i].type);
      pmap[i] = tempPMap[i];//p;
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
   for (uint i = median+1; i < pmap.size(); i++) {
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

//recursive variant
/*void KDTreeNode::locatePhotons(int i, glm::vec3 pt, Photon** locateHeap, int *heapSize, float sampleDistSqrd, float *newRadSqrd, glm::mat3 mInv, int numPhotons) {
   glm::vec3 rayBetween = pt - photon->pt;
   float distToPhotonSqrd = glm::length(rayBetween) * glm::length(rayBetween);
   
   if (2*i + 1 < numPhotons) {
      float distToPlane = 0.0f;
      //Find distance to plane (difference WRT splitting axis)
      if (axis == 0) distToPlane = pt.x - photon->pt.x;
      else if (axis == 1) distToPlane = pt.y - photon->pt.y;
      else if (axis == 2) distToPlane = pt.z - photon->pt.z;
      
      //Point is on the 'left' of the plane
      if (distToPlane < 0.0) {
         //Search on left child
         if (left != NULL) left->locatePhotons(2*i, pt, locateHeap, heapSize, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         //If distance to plane is less than the sample distance radius, then
         //sample sphere intersects plane, so check right child as well
         if (distToPlane*distToPlane < sampleDistSqrd) {
            if (right != NULL) right->locatePhotons(2*i + 1, pt, locateHeap, heapSize, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         }
      } else {
         //Point on 'right' of plane
         //Search on right child
         if (right != NULL) right->locatePhotons(2*i + 1, pt, locateHeap, heapSize, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         //If distance to plane is less than the sample distance radius, then
         //sample sphere intersects plane, so check left child as well
         if (distToPlane*distToPlane < sampleDistSqrd) {
            if (left != NULL) left->locatePhotons(2*i, pt, locateHeap, heapSize, sampleDistSqrd, newRadSqrd, mInv, numPhotons);
         }
      }
   }
   //Check if photon is close enough to the point
   if (distToPhotonSqrd <= sampleDistSqrd && *heapSize < CUTOFF_HEAP_SIZE) {
      glm::vec3 originLoc;
      originLoc = glm::vec3(photon->pt[0] - pt[0], photon->pt[1] - pt[1], photon->pt[2] - pt[2]);
      float rad = sqrt(sampleDistSqrd) * ELLIPSOID_SCALE;
      if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
         originLoc = originLoc * mInv;
      }
      if (((originLoc[0]*originLoc[0])/sampleDistSqrd) + ((originLoc[1]*originLoc[1])/sampleDistSqrd) + ((originLoc[2]*originLoc[2])/(rad*rad)) < 1.0) {
         locateHeap[*heapSize] = photon;
         *heapSize += 1;
         //cout << "INCIDENCE: " << -node->photon->incidence[0] << " " << -node->photon->incidence[1] << " " << -node->photon->incidence[2] << endl;
         //cout << "INTENSITY: " << node->photon->intensity[0] << " " << node->photon->intensity[1] << " " << node->photon->intensity[2] << endl;
         if (*heapSize == CUTOFF_HEAP_SIZE) {
            *newRadSqrd = distToPhotonSqrd;
         }
      }
   }
}*/

//iterative variant
void KDTreeNode::locatePhotons(glm::vec3 pt, Photon** locateHeap, int *heapSize, float sampleDistSqrd, float *newRadSqrd, glm::mat3 mInv, int numPhotons, KDTreeNode** stack) {
   
   glm::vec3 rayBetween;// = pt - photon->pt;
   float distToPhotonSqrd;// = glm::length(rayBetween) * glm::length(rayBetween);
   //float rad;
   //KDTreeNode **stack;
   //glm::vec3 originLoc;
   
   int added = 0;
   int stackMade = 0;
   
   
   //float distToPlane;
   
   
   
      int depth = 1;
   
   KDTreeNode *currentNode;// = this;
   KDTreeNode *previousNode = this;
   int currentStackSpot = 0;
   //depth *= 2;
   //KDTreeNode **stack;
   // Allocate space for the stack of nodes for the iterative solution
   //printf("prob this then\n");
   if (stack == NULL) {
      int treeLength = numPhotons;
      // Find depth of tree (should be balanced, but depth will be one more just to be very safe)
      while (treeLength != 0) {
         depth++;
         treeLength /= 2;
      }
      //printf("HSADFAHSF\n");
      //KDTreeNode **stack = (KDTreeNode **)malloc(depth * 2 * sizeof(KDTreeNode*));
      stack = (KDTreeNode **)malloc(depth * 2 * sizeof(KDTreeNode*));
      stackMade = 1;
   }
   //printf("where\n");
   //printf("confirming\n");
   //printf("HI\n");
   stack[currentStackSpot] = this;
   
   //printf("here?\n");
   //printf("DEPTH %d\n", depth);
   
   
   
   while (currentStackSpot >= 0) {
      //printf("%d\n", currentStackSpot);
      //printf("uhh\n");
      currentNode = stack[currentStackSpot];
      //printf("idk\n");
      
      if (currentNode->left != previousNode && currentNode->right != previousNode &&
          (currentNode->left != NULL || currentNode->right != NULL)) {
         //if (currentNode->left != NULL || currentNode->right != NULL) printf("k\n");
         //currentStackSpot++;
         //stack[currentStackSpot] = currentNode;
         //if (2*i + 1 < numPhotons) {
         float distToPlane = 0.0f;

         if (currentNode->axis == 0) distToPlane = pt.x - currentNode->photon->pt.x;
         else if (currentNode->axis == 1) distToPlane = pt.y - currentNode->photon->pt.y;
         else if (currentNode->axis == 2) distToPlane = pt.z - currentNode->photon->pt.z;
         
         if (distToPlane < 0.0) {
            if (distToPlane*distToPlane < sampleDistSqrd) {
               if (currentNode->right != NULL) {
                  currentStackSpot++;
                  stack[currentStackSpot] = currentNode->right;
                  added = 1;
               }
            }
            if (currentNode->left != NULL) {
               currentStackSpot++;
               stack[currentStackSpot] = currentNode->left;
               added = 1;
            }
         } else {
            if (distToPlane*distToPlane < sampleDistSqrd) {
               if (currentNode->left != NULL) {
                  currentStackSpot++;
                  stack[currentStackSpot] = currentNode->left;
                  added = 1;
               }
            }
            if (currentNode->right != NULL) {
               currentStackSpot++;
               stack[currentStackSpot] = currentNode->right;
               added = 1;
            }
         }
         
         // Add the current node back into the stack if it had children added
         // Otherwise modify the current stack spot
         if (!added) {
            if (currentNode->left == NULL) {
               previousNode = currentNode->right;
            } else {
               previousNode = currentNode->left;
            }
         } else {
            added = 0;
         }
         //}
      } else {
         //glm::vec3 rayBetween = pt - currentNode->photon->pt;
         //float distToPhotonSqrd = glm::length(rayBetween) * glm::length(rayBetween);
         //if (currentNode == NULL) printf("FUUUUUUUUUUCCCCCCCCCCCCCCCCCCCCKKKKKKKKKKKKKKKKKKKKKKKKKK\n");
         rayBetween = pt - currentNode->photon->pt;
         distToPhotonSqrd = glm::length(rayBetween) * glm::length(rayBetween);
         if (distToPhotonSqrd <= sampleDistSqrd && *heapSize < CUTOFF_HEAP_SIZE) {
            //printf("WWWOOOOOOOOOOOOOOOOOOOOOOOOO\n");
            glm::vec3 originLoc;
            //originLoc = currentNode->photon->pt - pt;
            
            originLoc = glm::vec3(currentNode->photon->pt[0] - pt[0], currentNode->photon->pt[1] - pt[1], currentNode->photon->pt[2] - pt[2]);
            float rad = sqrt(sampleDistSqrd) * ELLIPSOID_SCALE;
            //rad = sqrt(sampleDistSqrd) * ELLIPSOID_SCALE;
            if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
               originLoc = originLoc * mInv;
            }
            /*if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
               //originLoc = originLoc * mInv;
               originLoc[0] = (originLoc[0] * mInv[0][0]) + (originLoc[0] * mInv[0][1]) + (originLoc[0] * mInv[0][2]);
               originLoc[1] = (originLoc[0] * mInv[1][0]) + (originLoc[1] * mInv[1][1]) + (originLoc[1] * mInv[1][2]);
               originLoc[2] = (originLoc[0] * mInv[2][0]) + (originLoc[2] * mInv[2][1]) + (originLoc[2] * mInv[2][2]);
            }*/
            //originLoc[0] = mInv[0][0] + mInv[0][1] + mInv[0][2];
            //originLoc[1] = mInv[1][0] + mInv[1][1] + mInv[1][2];
            //originLoc[2] = mInv[2][0] + mInv[2][1] + mInv[2][2];
            //float oneoversampleDistsqrd = 1.0f / sampleDistSqrd;
            //rad = rad* rad);
            //float conditional = originLoc[0]*originLoc[0];
            //conditional = conditional + originLoc[1]*originLoc[1];
            //conditional = conditional / sampleDistSqrd;
            //rad = rad * rad;
            //originLoc[0] = originLoc[0] * originLoc[0];
            //originLoc[0] = originLoc[0] / sampleDistSqrd;
            //originLoc[1] = originLoc[1] * originLoc[1];
            //originLoc[1] = originLoc[1] / sampleDistSqrd;
            //originLoc[2] = originLoc[2] * originLoc[2];
            //originLoc[2] = originLoc[2] / rad;
            //conditional = conditional * rad;
            //conditional = conditional + originLoc[2]*originLoc[2];
            //conditional = conditional / rad;
            if (((originLoc[0]*originLoc[0])/sampleDistSqrd) + ((originLoc[1]*originLoc[1])/sampleDistSqrd) + ((originLoc[2]*originLoc[2])/(rad*rad)) < 1.0f) {
            //if (((originLoc[0]*originLoc[0])*oneoversampleDistsqrd) + ((originLoc[1]*originLoc[1])*oneoversampleDistsqrd) + ((originLoc[2]*originLoc[2])*oneoverradsqrd) < 1.0) {
            //if (conditional < 1.0f) {
               //printf("YOOOOOOOOOOOOOOOOOOOOOOOOO: %d\n", *heapSize);
               locateHeap[*heapSize] = currentNode->photon;
               *heapSize += 1;
               if (*heapSize == CUTOFF_HEAP_SIZE) {
                  *newRadSqrd = distToPhotonSqrd;
                  return;
               }
            }
         }
         previousNode = currentNode;
         currentStackSpot--;
      }
   }
   if (stackMade) {
     printf("FREEING STACK\n");   
      free(stack);
   }
}


/*void KDTreeNode::locatePhotons(glm::vec3 pt, int ts, Photon** locateHeap, float sampleDistSqrd, float *newRadSqrd, int numPhotons, float *sh) {
      //glm::vec3 rayBetween;// = pt - photon->pt;
   //float distToPhotonSqrd;// = glm::length(rayBetween) * glm::length(rayBetween);
   
   //KDTreeNode **stack;
    
   int added = 0;
   //int stackMade = 0;

   //depth *= 2;
   //KDTreeNode **stack;
   // Allocate space for the stack of nodes for the iterative solution
   //printf("prob this then\n");
   //if (stack == NULL) {
      volatile int treeLength = numPhotons;
      volatile int depth = 1;
      // Find depth of tree (should be balanced, but depth will be one more just to be very safe)
      while (treeLength != 0) {
         depth++;
         treeLength /= 2;
      }
      //printf("HSADFAHSF\n");
      KDTreeNode **stack = (KDTreeNode **)malloc(depth * 2 * sizeof(KDTreeNode*));
      //stackMade = 1;
   //}
   //printf("where\n");
   //printf("confirming\n");
   //printf("HI\n");
   stack[0] = this;
   
   //printf("here?\n");
   //printf("DEPTH %d\n", depth);
   
   volatile KDTreeNode *currentNode;// = this;
   volatile KDTreeNode *previousNode = this;
   volatile int currentStackSpot = 0;
   
   while (currentStackSpot >= 0) {
      //printf("%d\n", currentStackSpot);
      //printf("uhh\n");
      currentNode = stack[currentStackSpot];
      //printf("idk\n");
      
      if (currentNode->left != previousNode && currentNode->right != previousNode &&
          (currentNode->left != NULL || currentNode->right != NULL)) {
         //if (currentNode->left != NULL || currentNode->right != NULL) printf("k\n");
         //currentStackSpot++;
         //stack[currentStackSpot] = currentNode;
         //if (2*i + 1 < numPhotons) {
         float distToPlane = 0.0f;

         if (currentNode->axis == 0) distToPlane = pt.x - currentNode->photon->pt.x;
         else if (currentNode->axis == 1) distToPlane = pt.y - currentNode->photon->pt.y;
         else if (currentNode->axis == 2) distToPlane = pt.z - currentNode->photon->pt.z;
         
         if (distToPlane < 0.0) {
            if (distToPlane*distToPlane < sampleDistSqrd) {
               if (currentNode->right != NULL) {
                  currentStackSpot++;
                  stack[currentStackSpot] = currentNode->right;
                  added = 1;
               }
            }
            if (currentNode->left != NULL) {
               currentStackSpot++;
               stack[currentStackSpot] = currentNode->left;
               added = 1;
            }
         } else {
            if (distToPlane*distToPlane < sampleDistSqrd) {
               if (currentNode->left != NULL) {
                  currentStackSpot++;
                  stack[currentStackSpot] = currentNode->left;
                  added = 1;
               }
            }
            if (currentNode->right != NULL) {
               currentStackSpot++;
               stack[currentStackSpot] = currentNode->right;
               added = 1;
            }
         }
         
         // Add the current node back into the stack if it had children added
         // Otherwise modify the current stack spot
         if (!added) {
            if (currentNode->left == NULL) {
               previousNode = currentNode->right;
            } else {
               previousNode = currentNode->left;
            }
         } else {
            added = 0;
         }
         //}
      } else {
         glm::vec3 rayBetween = pt - currentNode->photon->pt;
         volatile float distToPhotonSqrd = glm::length(rayBetween) * glm::length(rayBetween);
         if (distToPhotonSqrd <= sampleDistSqrd && (int)sh[ts] < CUTOFF_HEAP_SIZE) {
         //if (distToPhotonSqrd <= sampleDistSqrd && *heapSize < CUTOFF_HEAP_SIZE) {
            glm::vec3 originLoc = currentNode->photon->pt - pt;
            //glm::vec3 originLoc(currentNode->photon->pt.x - sh[pt], currentNode->photon->pt.y - sh[pt+1], currentNode->photon->pt.z - sh[pt+2]);
            //originLoc = glm::vec3(currentNode->photon->pt[0] - pt[0], currentNode->photon->pt[1] - pt[1], currentNode->photon->pt[2] - pt[2]);
            volatile float rad = sqrt(sampleDistSqrd) * ELLIPSOID_SCALE;
            //if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
               //originLoc = originLoc * mInv;
               //originLoc[0] = (originLoc[0] * mInv[0][0]) + (originLoc[0] * mInv[0][1]) + (originLoc[0] * mInv[0][2]);
               //originLoc[1] = (originLoc[0] * mInv[1][0]) + (originLoc[1] * mInv[1][1]) + (originLoc[1] * mInv[1][2]);
               //originLoc[2] = (originLoc[0] * mInv[2][0]) + (originLoc[2] * mInv[2][1]) + (originLoc[2] * mInv[2][2]);
            //}

            if (((originLoc[0]*originLoc[0])/sampleDistSqrd) + ((originLoc[1]*originLoc[1])/sampleDistSqrd) + ((originLoc[2]*originLoc[2])/(rad*rad)) < 1.0f) {
            //if (((originLoc[0]*originLoc[0])*oneoversampleDistsqrd) + ((originLoc[1]*originLoc[1])*oneoversampleDistsqrd) + ((originLoc[2]*originLoc[2])*oneoverradsqrd) < 1.0) {
            //if (conditional < 1.0f) {
               locateHeap[(int)sh[ts]] = currentNode->photon;
               sh[ts] += 1;
               if ((int)sh[ts] == CUTOFF_HEAP_SIZE) {
                  *newRadSqrd = distToPhotonSqrd;
                  return;
               }
            }
            //if (((sh[pt+4]*sh[pt+4])/sh[pt+9]) + ((sh[pt+5]*sh[pt+5])/sh[pt+9]) + ((sh[pt+6]*sh[pt+6])/(rad*rad)) < 1.0f) {
            //if (((originLoc[0]*originLoc[0])/sampleDistSqrd) + ((originLoc[1]*originLoc[1])/sampleDistSqrd) + ((originLoc[2]*originLoc[2])/(rad*rad)) < 1.0f) {
               //locateHeap[(int)sh[pt+10]] = currentNode->photon;
               //sh[pt+10] += 1;
               //if ((int)sh[pt+10] == CUTOFF_HEAP_SIZE) {
               //   *nrs = sh[pt+7];
               //   return;
               //}
            //}
         }
         previousNode = currentNode;
         currentStackSpot--;
      }
   }
   //if (stackMade) {
   //  printf("FREEING STACK\n");   
   //   free(stack);
   //}
}*/


/*void KDTreeNode::locatePhotons(int pt, volatile Photon** locateHeap, float sampleDistSqrd, float *newRadSqrd, int numPhotons, float *sh) {
   //extern __shared__ float sh[];
   //volatile int added = 0;
   sh[pt+5] = 0.001;

      volatile int treeLength = numPhotons;
      volatile int depth = 1;
      while (treeLength != 0) {
         depth++;
         treeLength /= 2;
      }
      KDTreeNode **stack = (KDTreeNode **)malloc(depth * 2 * sizeof(KDTreeNode*));
      printf("DEPTH:%d\n", depth);
   stack[0] = this;
   
   volatile KDTreeNode *currentNode;// = this;
   volatile KDTreeNode *previousNode = this;
   sh[pt+8] = 0.1;
   volatile KDTreeNode *what;
   sh[pt+9] = sampleDistSqrd;
   volatile float * nrs = newRadSqrd;
   
   while (sh[pt+8] >= 0) {
      currentNode = stack[(int)sh[pt+8]];
      
      if (currentNode->left != previousNode && currentNode->right != previousNode &&
          (currentNode->left != NULL || currentNode->right != NULL)) {
         //volatile float distToPlane = 0.0f;
         sh[pt+7] = 0.0f;
         //volatile glm::vec3
         if (currentNode->axis == 0) sh[pt+7] = sh[pt] - currentNode->photon->pt.x;
         else if (currentNode->axis == 1) sh[pt+7] = sh[pt+1] - currentNode->photon->pt.y;
         else if (currentNode->axis == 2) sh[pt+7] = sh[pt+2] - currentNode->photon->pt.z;
         
         if (sh[pt+7] < 0.0) {
            if (sh[pt+7]*sh[pt+7] < sh[pt+9]) {
               if (currentNode->right != NULL) {
                  sh[pt+8]+=1;
                  stack[(int)sh[pt+8]] = currentNode->right;
                  //what = currentNode->right;
                  //stack[(int)sh[pt+8]] = what;
                  sh[pt+5] = 1.1;
               }
            }
            if (currentNode->left != NULL) {
               sh[pt+8]+=1;
               stack[(int)sh[pt+8]] = currentNode->left;
               //what = currentNode->left;
               //stack[(int)sh[pt+8]] = what;
               sh[pt+5] = 1.1;
            }
         } else {
            if (sh[pt+7]*sh[pt+7] < sh[pt+9]) {
               if (currentNode->left != NULL) {
                  sh[pt+8]+=1;
                  stack[(int)sh[pt+8]] = currentNode->left;
                  //what = currentNode->left;
                  //stack[(int)sh[pt+8]] = what;
                  sh[pt+5] = 1.1;
               }
            }
            if (currentNode->right != NULL) {
               sh[pt+8]+=1;
               stack[(int)sh[pt+8]] = currentNode->right;
               //what = currentNode->right;
               //stack[(int)sh[pt+8]] = what;
               sh[pt+5] = 1.1;
            }
         }
         
         if (!((int)sh[pt+5])) {
            if (currentNode->left == NULL) {
               previousNode = currentNode->right;
            } else {
               previousNode = currentNode->left;
            }
         } else {
            sh[pt+5] = 0.1;
         }
      } else {
         //glm::vec3 rayBetween;
         //rayBetween.x = sh[pt] - currentNode->photon->pt.x;
         //rayBetween.y = sh[pt+1] - currentNode->photon->pt.y;
         //rayBetween.z = sh[pt+2] - currentNode->photon->pt.z;
         //sh[pt+4] = sh[pt] - currentNode->photon->pt.x;
         //sh[pt+5] = sh[pt+1] - currentNode->photon->pt.y;
         //sh[pt+6] = sh[pt+2] - currentNode->photon->pt.z;
         //volatile glm::vec3 rayBetween = glm::vec3(sh[pt] - currentNode->photon->pt.x, sh[pt+1] - currentNode->photon->pt.y, sh[pt+2] - currentNode->photon->pt.z);
         glm::vec3 rayBetween = glm::vec3(sh[pt] - currentNode->photon->pt.x, sh[pt+1] - currentNode->photon->pt.y, sh[pt+2] - currentNode->photon->pt.z);
         //volatile float sum = sh[pt+4] * sh[pt+4];
         //sum += sh[pt+5] * sh[pt+5];
         //sum += sh[pt+6] * sh[pt+6];
         //volatile float rb = sqrt(rayBetween.x * rayBetween.x + rayBetween.y * rayBetween.y + rayBetween.z * rayBetween.z);
         //volatile float rb = sqrt(sum);
         //volatile float distToPhotonSqrd = glm::length(rayBetween) * glm::length(rayBetween);
         sh[pt+7] = glm::length(rayBetween) * glm::length(rayBetween);
         if (sh[pt+7] <= sh[pt+9] && sh[pt+10] < CUTOFF_HEAP_SIZE) {
            glm::vec3 originLoc(currentNode->photon->pt.x - sh[pt], currentNode->photon->pt.y - sh[pt+1], currentNode->photon->pt.z - sh[pt+2]);
            //sh[pt+4] = currentNode->photon->pt.x - sh[pt];
            //sh[pt+5] = currentNode->photon->pt.y - sh[pt+1];
            //sh[pt+6] = currentNode->photon->pt.z - sh[pt+2];
            
            volatile float rad = sqrt(sh[pt+9]) * ELLIPSOID_SCALE;
            //sh[pt+6] = sqrt(sh[pt+9]) * ELLIPSOID_SCALE;
            //volatile float sds = sampleDistSqrd;
            //if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE) {
            //   sh[pt+4] = (sh[pt+4] * mInv[0][0]) + (sh[pt+4] * mInv[0][1]) + (sh[pt+4] * mInv[0][2]);
            //   sh[pt+5] = (sh[pt+5] * mInv[1][0]) + (sh[pt+5] * mInv[1][1]) + (sh[pt+5] * mInv[1][2]);
            //   sh[pt+6] = (sh[pt+6] * mInv[2][0]) + (sh[pt+6] * mInv[2][1]) + (sh[pt+6] * mInv[2][2]);
            //}
            if (((sh[pt+4]*sh[pt+4])/sh[pt+9]) + ((sh[pt+5]*sh[pt+5])/sh[pt+9]) + ((sh[pt+6]*sh[pt+6])/(rad*rad)) < 1.0f) {
            //if (((originLoc[0]*originLoc[0])/sampleDistSqrd) + ((originLoc[1]*originLoc[1])/sampleDistSqrd) + ((originLoc[2]*originLoc[2])/(rad*rad)) < 1.0f) {
               locateHeap[(int)sh[pt+10]] = currentNode->photon;
               sh[pt+10] += 1;
               if ((int)sh[pt+10] == CUTOFF_HEAP_SIZE) {
                  *nrs = sh[pt+7];
                  return;
               }
            }
         }
         previousNode = currentNode;
         sh[pt+8]-=1;
      }
   }
}*/

int KDTreeNode::Treesize() {
   int num = 1;
   if (this->left != NULL) num += this->left->Treesize();
   if (this->right != NULL) num += this->right->Treesize();
   return num;
}
void KDTreeNode::printTree(KDTreeNode *node) {
   //std::cout << "Pt: " << glm::to_string(node->photon->pt) << std::endl;
   printf("Pt: %f %f %f\n", node->photon->pt.x, node->photon->pt.y, node->photon->pt.z);
   printf("Axis Split: %d\n", node->axis);
   if (node->left != NULL) {
      printf("LEFT\n");
      printTree(node->left);
      printf("BACK\n");
   }
   if (node->right != NULL) {
      printf("RIGHT\n");
      printTree(node->right);
      printf("BACK\n");
   }
}

float KDTreeNode::findMin(std::vector<Photon*> pmap, int axis) {
   float min = 0.0f;
   for (uint i = 0; i < pmap.size(); i++) {
      if (i == 0 || pmap[i]->pt[axis] < min) {
         min = pmap[i]->pt[axis];
      }
   }
   return min;
}

float KDTreeNode::findMax(std::vector<Photon*> pmap, int axis) {
   float max = 0.0f;
   for (uint i = 0; i < pmap.size(); i++) {
      if (i == 0 || pmap[i]->pt[axis] > max) {
         max = pmap[i]->pt[axis];
      }
   }
   
   /* CODY, THIS IS WRONG, YOU SHOULD KNOW THAT.
   YOU WANT TO RETURN MIN */
   return max;
}

void KDTreeNode::toSerialArray(Photon *objectArray, int *currentIndex) {
   int i;
   int thisInd = *currentIndex;
   *currentIndex += 2;
   
   /*memcpy(objectArray + (*currentIndex), this, sizeof(KDTreeNode));
   *currentIndex += 1;
   memcpy(objectArray + (*currentIndex), photon, sizeof(Photon));
   *currentIndex += 1;*/
   
   if (left) {
      leftInd = *currentIndex;
      left->toSerialArray(objectArray, currentIndex);
   }
   if (right) {
      rightInd = *currentIndex;
      right->toSerialArray(objectArray, currentIndex);
   }
   
   memcpy(objectArray + thisInd, this, sizeof(KDTreeNode));
   memcpy(objectArray + thisInd + 1, photon, sizeof(Photon));
}

bool compPhotons(Photon* p1, Photon* p2) { 
   if (p1->sortAxis == 0) {
      return p1->pt.x < p2->pt.x;
   } else if (p1->sortAxis == 1) {
      return p1->pt.y < p2->pt.y;
   } else if (p1->sortAxis == 2) {
      return p1->pt.z < p2->pt.z;
   } else {
      return false; //fuck
   }
}
