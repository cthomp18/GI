/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "QuadTreeNode.h"

#define TOLERANCE 0.001

using namespace std;

int sortAxisQuad = 0;

bool sorterQuad(SceneObject* s1, SceneObject* s2) { 
   if (sortAxisQuad == 0) {
      return s1->boundingBox->middle.x() < s2->boundingBox->middle.x();
   } else if (sortAxisQuad == 2) {
      return s1->boundingBox->middle.z() < s2->boundingBox->middle.z();
   } else {
      std::cout << "fuck" << std::endl;
      return false; //fuck
   }
}

QuadTreeNode::QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth) : SceneObject() {
   int middle, quarter;
   std::vector<SceneObject*> tempVect1, tempVect2;
   SceneObject *obj1, *obj2, *obj3, *obj4;
   
   hitObj = q1 = q2 = q3 = q4 = obj1 = obj2 = obj3 = obj4 = NULL;
   
   /*std::cout << "Depth: " << depth << std::endl;
   for (int i = 0; i < objects.size(); i++) {
      objects[i]->printObj();
   }*/
   
   if (n <= 4) {
      q1 = objects[0];
      obj1 = q1;
      if (n >= 2) q2 = obj2 = objects[1];
      else obj2 = objects[0];
      if (n >= 3) q3 = obj3 = objects[2];
      else obj3 = objects[0];
      if (n == 4) q4 = obj4 = objects[3];
      else obj4 = objects[0];

      boundingBox = combineBB(obj1->boundingBox, obj2->boundingBox, obj3->boundingBox, obj4->boundingBox);
   } else {      
      //std::cout << sortAxis << std::endl;
      sortAxisQuad = 0;
      std::sort(objects.begin(), objects.end(), sorterQuad);
      sortAxisQuad = 2;
      
      /*std::cout << "---------------New Recurse---------------------" << std::endl;
      std::cout << "SortAxis: " << sortAxis << std::endl;
      for (int i = 0; i < n; i++) {
         std::cout << objects[i]->boundingBox->middle.x() << " " << objects[i]->boundingBox->middle.y() << " " << objects[i]->boundingBox->middle.z() << std::endl;
      }*/
      
      middle = n / 2;
      quarter = middle / 2;
      
      tempVect1.clear();
      for (int i = 0; i < middle; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterQuad);
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      q1 = new QuadTreeNode(tempVect2, quarter, depth + 1);
      
      tempVect2.clear();
      for (int i = quarter; i < middle; i++) tempVect2.push_back(tempVect1[i]);
      q2 = new QuadTreeNode(tempVect2, tempVect2.size(), depth + 1);
      
      tempVect1.clear();
      for (int i = middle; i < n; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterQuad);
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      q3 = new QuadTreeNode(tempVect2, quarter, depth + 1);
      
      tempVect2.clear();
      for (int i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      q4 = new QuadTreeNode(tempVect2, tempVect2.size(), depth + 1);
      
      boundingBox = combineBB(q1->boundingBox, q2->boundingBox, q3->boundingBox, q4->boundingBox);
   }
   type = 8;
}

QuadTreeNode::QuadTreeNode() : SceneObject() {}
QuadTreeNode::~QuadTreeNode() {}

float QuadTreeNode::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object) {
   Eigen::Vector4f startTransform;
   float t, tempT;
   SceneObject *obj1, *obj2, *obj3, *obj4;
   t = tempT = -1.0f;
   //hitObj = NULL;
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform << start, 1.0f;
   if (boundingBox->checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   

   if (q1->transformed) {
      t = q1->checkCollision((q1->transform * startTransform).segment<3>(0), q1->transform.block<3,3>(0,0) * ray, time, &obj1);
   } else {
      t = q1->checkCollision(start, ray, time, &obj1);
   }
   *object = obj1;

   if (q2) {
      if (t >= TOLERANCE) {
         tempT = q2->boundingBox->checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q2->transformed) {
               tempT = q2->checkCollision((q2->transform * startTransform).segment<3>(0), q2->transform.block<3,3>(0,0) * ray, time, &obj2);
            } else {
               tempT = q2->checkCollision(start, ray, time, &obj2);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj2;
            }
         }
      } else {
         t = q2->checkCollision((q2->transform * startTransform).segment<3>(0), q2->transform.block<3,3>(0,0) * ray, time, &obj2);
         *object = obj2;
      }
   }
   
   if (q3) {
      if (t >= TOLERANCE) {
         tempT = q3->boundingBox->checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q3->transformed) {
               tempT = q3->checkCollision((q3->transform * startTransform).segment<3>(0), q3->transform.block<3,3>(0,0) * ray, time, &obj3);
            } else {
               tempT = q3->checkCollision(start, ray, time, &obj3);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj3;
            }
         }
      } else {
         t = q3->checkCollision((q3->transform * startTransform).segment<3>(0), q3->transform.block<3,3>(0,0) * ray, time, &obj3);
         *object = obj3;
      }
   }
   
   if (q4) {
      if (t >= TOLERANCE) {
         tempT = q4->boundingBox->checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q4->transformed) {
               tempT = q4->checkCollision((q4->transform * startTransform).segment<3>(0), q4->transform.block<3,3>(0,0) * ray, time, &obj4);
            } else {
               tempT = q4->checkCollision(start, ray, time, &obj4);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj4;
            }
         }
      } else {
         t = q4->checkCollision((q4->transform * startTransform).segment<3>(0), q4->transform.block<3,3>(0,0) * ray, time, &obj4);
         *object = obj4;
      }
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   //left->hitObj = NULL;
   //if (right) right->hitObj = NULL;
   
   return t;
}

Eigen::Vector3f QuadTreeNode::getNormal(Eigen::Vector3f iPt) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return Eigen::Vector3f(0.0f, 0.0f, 0.0f);
}

SceneObject* QuadTreeNode::getObj() {
   return hitObj;
}


/*void QuadTreeNode::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - rad, position[1] - rad, position[2] - rad),
                         Eigen::Vector3f(position[0] + rad, position[1] + rad, position[2] + rad));
}*/

void QuadTreeNode::printObj() {
   cout << "hello?" << endl;
   if (q1->type == 2) { cout << "wut" << endl; }
   q1->printObj();
   if (q2) q2->printObj();
   if (q3) q3->printObj();
   if (q4) q4->printObj();
}

Box* QuadTreeNode::combineBB(Box* box1, Box* box2, Box* box3, Box* box4) {
   return new Box(Eigen::Vector3f(fmin(fmin(fmin(box1->minPt[0], box2->minPt[0]), box3->minPt[0]), box4->minPt[0]),
                                  fmin(fmin(fmin(box1->minPt[1], box2->minPt[1]), box3->minPt[1]), box4->minPt[1]),
                                  fmin(fmin(fmin(box1->minPt[2], box2->minPt[2]), box3->minPt[2]), box4->minPt[2])),
                  Eigen::Vector3f(fmax(fmax(fmax(box1->maxPt[0], box2->maxPt[0]), box3->maxPt[0]), box4->maxPt[0]),
                                  fmax(fmax(fmax(box1->maxPt[1], box2->maxPt[1]), box3->maxPt[1]), box4->maxPt[1]),
                                  fmax(fmax(fmax(box1->maxPt[2], box2->maxPt[2]), box3->maxPt[2]), box4->maxPt[2])));
}
