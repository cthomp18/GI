/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "QuadTreeNode.h"

#define TOLERANCE 0.001

using namespace std;

int sortAxisQuad = 0;

bool sorterQuad(SceneObject* s1, SceneObject* s2) { 
   if (sortAxisQuad == 0) {
      return s1->boundingBox.middle.x < s2->boundingBox.middle.x;
   } else if (sortAxisQuad == 2) {
      return s1->boundingBox.middle.z < s2->boundingBox.middle.z;
   } else {
      std::cout << "fuck" << std::endl;
      return false;
   }
}

QuadTreeNode::QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth) : SceneObject() {
   int middle, quarter, curInd = 0;
   std::vector<SceneObject*> tempVect1, tempVect2;
   std::vector<SceneObject*> objs;
   std::vector<BoundingBox*> bbs;
   
   objs.clear();
   bbs.clear();
   
   for (int i = 0; i < 4; i++) {
      quadrants[i] = NULL;
      indeces[i] = -1;
      objs.push_back(NULL);
   }
   
   if (n <= 4) {
      for (int i = 0; i < 4; i++) {
         if (i + 1 <= n) quadrants[i] = objs[i] = objects[i];
      }
      
      for (int i = 0; i < n; i++) {
         bbs.push_back(&(objs[i]->boundingBox));
      }
      
      boundingBox = combineBB(bbs);
   } else {      
      sortAxisQuad = 0;
      std::sort(objects.begin(), objects.end(), sorterQuad);
      sortAxisQuad = 2;
      
      middle = n / 2;
      quarter = middle / 2;
      
      tempVect1.clear();
      for (int i = 0; i < middle; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterQuad);
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      if (quarter) quadrants[curInd++] = new QuadTreeNode(tempVect2, quarter, depth + 1);
      
      tempVect2.clear();
      for (int i = quarter; i < middle; i++) tempVect2.push_back(tempVect1[i]);
      if (quarter != tempVect1.size()) quadrants[curInd++] = new QuadTreeNode(tempVect2, tempVect2.size(), depth + 1);
      
      tempVect1.clear();
      for (int i = middle; i < n; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterQuad);
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      if (quarter) quadrants[curInd++] = new QuadTreeNode(tempVect2, quarter, depth + 1);
      
      tempVect2.clear();
      for (uint i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      if (quarter != tempVect1.size()) quadrants[curInd++] = new QuadTreeNode(tempVect2, tempVect2.size(), depth + 1);
      
      for (int i = 0; i < curInd; i++) {
         bbs.push_back(&(quadrants[i]->boundingBox));
      }
      boundingBox = combineBB(bbs);
   }
   type = 7;
   
   checkCollision = &(checkQuadTreeCollision);
   getNormal = &(getQuadTreeNormal);
}

QuadTreeNode::QuadTreeNode() : SceneObject() {}
QuadTreeNode::~QuadTreeNode() {
   for (int i = 0; i < 4; i++) {
      if (quadrants[i]) delete quadrants[i];
   }
}

void QuadTreeNode::printObj() {
   for (int i = 0; i < 4; i++) {
      if (quadrants[i]) quadrants[i]->printObj();
   }
}

BoundingBox QuadTreeNode::combineBB(std::vector<BoundingBox*> boxes) {
   float xmin = boxes[0]->minPt[0], ymin = boxes[0]->minPt[1], zmin = boxes[0]->minPt[2];
   float xmax = boxes[0]->maxPt[0], ymax = boxes[0]->maxPt[1], zmax = boxes[0]->maxPt[2];
   for (uint i = 1; i < boxes.size(); i++) {
      xmin = fmin(xmin, boxes[i]->minPt[0]);
      ymin = fmin(ymin, boxes[i]->minPt[1]);
      zmin = fmin(zmin, boxes[i]->minPt[2]);
      xmax = fmax(xmax, boxes[i]->maxPt[0]);
      ymax = fmax(ymax, boxes[i]->maxPt[1]);
      zmax = fmax(zmax, boxes[i]->maxPt[2]);
   }
   return BoundingBox(glm::vec3(xmin, ymin, zmin), glm::vec3(xmax, ymax, zmax));
}

int QuadTreeNode::treeLength() {
   int length = 1;
   
   for (int i = 0; i < 4; i++) {
      if (quadrants[i]) {
         if (quadrants[i]->type != 7) {
            length++;
         } else {
            length += static_cast<QuadTreeNode*>(quadrants[i])->treeLength();
         }
      }
   }
   
   return length;
}

void QuadTreeNode::toSerialArray(Triangle *objectArray, int *currentIndex) {
   int i;
   int thisInd = *currentIndex;
   
   *currentIndex += 1;
   
   for (i = 0; i < 4; i++) {
      if (quadrants[i]) {
         indeces[i] = *currentIndex;
         if (quadrants[i]->type != 7) {
            assert(quadrants[i]->type == 2);
            memcpy(objectArray + (*currentIndex), quadrants[i], sizeof(Triangle));
            *currentIndex += 1;
         } else {
            reinterpret_cast<QuadTreeNode*>(quadrants[i])->toSerialArray(objectArray, currentIndex);
         }
      }
   }
   
   memcpy(objectArray + thisInd, this, sizeof(QuadTreeNode));
}
