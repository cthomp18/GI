/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "BiTreeNode.h"

#define TOLERANCE 0.001

int sortAxisBi = 0;

bool sorterBi(SceneObject* s1, SceneObject* s2) { 
   if (sortAxisBi == 0) {
      return s1->boundingBox->middle.x() < s2->boundingBox->middle.x();
   } else if (sortAxisBi == 1) {
      return s1->boundingBox->middle.y() < s2->boundingBox->middle.y();
   } else if (sortAxisBi == 2) {
      return s1->boundingBox->middle.z() < s2->boundingBox->middle.z();
   } else {
      std::cout << "fuck" << std::endl;
      return false; //fuck
   }
}

BiTreeNode::BiTreeNode(std::vector<SceneObject*> objects, int axis, int n) : SceneObject() {
   int middle;
   std::vector<SceneObject*> tempVect1, tempVect2;
   
   sortAxisBi = 0;
   hitObj = NULL;
   if (n == 1) {
      left = objects[0];
      right = NULL;
      boundingBox = objects[0]->boundingBox;
   } else if (n == 2) {
      left = objects[0];
      right = objects[1];
      boundingBox = combineBB(objects[0]->boundingBox, objects[1]->boundingBox);
   } else {      
      //tempVect.clear();
      float minx, miny, minz, maxx, maxy, maxz;
      minx = miny = minz = FLT_MAX;
      maxx = maxy = maxz = FLT_MIN;
      Eigen::Vector3f mid;
      for (int i = 0; i < n; i++) {
         mid = objects[i]->boundingBox->middle;
         if (minx > mid.x()) minx = mid.x();
         if (maxx < mid.x()) maxx = mid.x();
         if (miny > mid.y()) miny = mid.y();
         if (maxy < mid.y()) maxy = mid.y();
         if (minz > mid.z()) minz = mid.z();
         if (maxz < mid.z()) maxz = mid.z();
      }
      
      if (maxx - minx > maxy - miny && maxx - minx > maxz - minz) {
         sortAxisBi = 0;
      } else {
         if (maxy - miny > maxz - minz) {
            sortAxisBi = 1;
         } else {
            sortAxisBi = 2;
         }
      }
      //std::cout << "---------------Un   Sorted---------------------" << std::endl;
      
      //std::cout << sortAxis << std::endl;
      std::sort(objects.begin(), objects.end(), sorterBi);
      
      /*std::cout << "---------------New Recurse---------------------" << std::endl;
      std::cout << "SortAxis: " << sortAxis << std::endl;
      for (int i = 0; i < n; i++) {
         std::cout << objects[i]->boundingBox->middle.x() << " " << objects[i]->boundingBox->middle.y() << " " << objects[i]->boundingBox->middle.z() << std::endl;
      }*/
      
      middle = n / 2;
      tempVect1.clear();
      tempVect2.clear();
      for (int i = 0; i < middle; i++) {
         tempVect1.push_back(objects[i]);
      }
      for (int i = middle; i < n; i++) {
         tempVect2.push_back(objects[i]);
      }
      //std::cout << n << " " << middle << std::endl;
      left = new BiTreeNode(tempVect1, (axis + 1) % 3, tempVect1.size());
      right = new BiTreeNode(tempVect2, (axis + 1) % 3, tempVect2.size());
      
      boundingBox = combineBB(left->boundingBox, right->boundingBox);
   }
   type = 8;
}

BiTreeNode::BiTreeNode() : SceneObject() {}
BiTreeNode::~BiTreeNode() {}

float BiTreeNode::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object) {
   Eigen::Vector4f startTransform;
   float t, tLeft, tRight;
   SceneObject *lObj, *rObj;
   t = tLeft = tRight = -1.0f;
   //hitObj = NULL;
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform << start, 1.0f;
   if (boundingBox->checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   //if (left) {
   if (left->transformed) {
      tLeft = left->checkCollision((left->transform * startTransform).segment<3>(0), left->transform.block<3,3>(0,0) * ray, time, &lObj);
   } else {
      tLeft = left->checkCollision(start, ray, time, &lObj);
   }
   if (right) {
      if (tLeft >= TOLERANCE) {
         tRight = right->boundingBox->checkCollision(start, ray, time);
         if (tRight >= TOLERANCE && tRight < tLeft) {
            if (right->transformed) {
               tRight = right->checkCollision((right->transform * startTransform).segment<3>(0), right->transform.block<3,3>(0,0) * ray, time, &rObj);
            } else {
               tRight = right->checkCollision(start, ray, time, &rObj);
            }
         } else {
            tRight = -1.0f;
         }
      } else {
         tRight = right->checkCollision((right->transform * startTransform).segment<3>(0), right->transform.block<3,3>(0,0) * ray, time, &rObj);
      }
   }
   //}
   
   if (tLeft < TOLERANCE) {
      if (tRight >= TOLERANCE) {
         t = tRight;
         *object = rObj;
      }
   } else {
      if (tRight < TOLERANCE) {
         t = tLeft;
         *object = lObj;
      } else {
         if (tLeft < tRight) {
            t = tLeft;
            *object = lObj;
         } else {
            t = tRight;
            *object = rObj;
         }
      }
   }
   
   //left->hitObj = NULL;
   //if (right) right->hitObj = NULL;
   
   return t;
}

Eigen::Vector3f BiTreeNode::getNormal(Eigen::Vector3f iPt) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return Eigen::Vector3f(0.0f, 0.0f, 0.0f);
}

SceneObject* BiTreeNode::getObj() {
   return hitObj;
}


/*void BiTreeNode::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - rad, position[1] - rad, position[2] - rad),
                         Eigen::Vector3f(position[0] + rad, position[1] + rad, position[2] + rad));
}*/

void BiTreeNode::printTree() {
   
}

Box* BiTreeNode::combineBB(Box* box1, Box* box2) {
   return new Box(Eigen::Vector3f(fmin(box1->minPt[0], box2->minPt[0]), fmin(box1->minPt[1], box2->minPt[1]), fmin(box1->minPt[2], box2->minPt[2])),
                  Eigen::Vector3f(fmax(box1->maxPt[0], box2->maxPt[0]), fmax(box1->maxPt[1], box2->maxPt[1]), fmax(box1->maxPt[2], box2->maxPt[2])));
}
