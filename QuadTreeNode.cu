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
      return false; //fuck
   }
}

QuadTreeNode::QuadTreeNode(std::vector<SceneObject*> objects, int n, int depth) : SceneObject() {
   int middle, quarter;
   std::vector<SceneObject*> tempVect1, tempVect2;
   SceneObject *obj1, *obj2, *obj3, *obj4;
   
   q1 = q2 = q3 = q4 = obj1 = obj2 = obj3 = obj4 = NULL;
   
   /*std::cout << "Depth: " << depth << std::endl;
   for (int i = 0; i < objects.size(); i++) {
      objects[i]->printObj();
   }*/
   indeces[0] = indeces[1] = indeces[2] = indeces[3] = -1;
   if (n <= 4) {
      q1 = objects[0];
      obj1 = q1;
      if (n >= 2) q2 = obj2 = objects[1];
      else obj2 = objects[0];
      if (n >= 3) q3 = obj3 = objects[2];
      else obj3 = objects[0];
      if (n == 4) q4 = obj4 = objects[3];
      else obj4 = objects[0];

      boundingBox = combineBB(&(obj1->boundingBox), &(obj2->boundingBox), &(obj3->boundingBox), &(obj4->boundingBox));
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
      for (uint i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      q4 = new QuadTreeNode(tempVect2, tempVect2.size(), depth + 1);
      
      boundingBox = combineBB(&(q1->boundingBox), &(q2->boundingBox), &(q3->boundingBox), &(q4->boundingBox));
   }
   type = 7;
   
   checkCollision = &(checkQuadTreeCollision);
   getNormal = &(getQuadTreeNormal);
}

QuadTreeNode::QuadTreeNode() : SceneObject() {}
QuadTreeNode::~QuadTreeNode() {
   if (q1) delete q1;
   if (q2) delete q2;
   if (q3) delete q3;
   if (q4) delete q4;
}

/*float QuadTreeNode::checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   glm::vec4 startTransform;
   float t, tempT;
   SceneObject *obj1, *obj2, *obj3, *obj4;
   t = tempT = -1.0f;
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (boundingBox.checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   

   if (q1->transformed) {
      t = q1->checkCollision(glm::vec3(q1->transform * startTransform), glm::mat3(q1->transform) * ray, time, &obj1);
   } else {
      t = q1->checkCollision(start, ray, time, &obj1);
   }
   *object = obj1;

   if (q2) {
      if (t >= TOLERANCE) {
         tempT = q2->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q2->transformed) {
               tempT = q2->checkCollision(glm::vec3(q2->transform * startTransform), glm::mat3(q2->transform) * ray, time, &obj2);
            } else {
               tempT = q2->checkCollision(start, ray, time, &obj2);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj2;
            }
         }
      } else {
         t = q2->checkCollision(glm::vec3(q2->transform * startTransform), glm::mat3(q2->transform) * ray, time, &obj2);
         *object = obj2;
      }
   }
   
   if (q3) {
      if (t >= TOLERANCE) {
         tempT = q3->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q3->transformed) {
               tempT = q3->checkCollision(glm::vec3(q3->transform * startTransform), glm::mat3(q3->transform) * ray, time, &obj3);
            } else {
               tempT = q3->checkCollision(start, ray, time, &obj3);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj3;
            }
         }
      } else {
         t = q3->checkCollision(glm::vec3(q3->transform * startTransform), glm::mat3(q3->transform) * ray, time, &obj3);
         *object = obj3;
      }
   }
   
   if (q4) {
      if (t >= TOLERANCE) {
         tempT = q4->boundingBox.checkCollision(start, ray, time);
         if (tempT >= TOLERANCE && tempT < t) {
            if (q4->transformed) {
               tempT = q4->checkCollision(glm::vec3(q4->transform * startTransform), glm::mat3(q4->transform) * ray, time, &obj4);
            } else {
               tempT = q4->checkCollision(start, ray, time, &obj4);
            }
            if (tempT >= TOLERANCE && tempT < t) {
               t = tempT;
               *object = obj4;
            }
         }
      } else {
         t = q4->checkCollision(glm::vec3(q4->transform * startTransform), glm::mat3(q4->transform) * ray, time, &obj4);
         *object = obj4;
      }
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;
}*/

/*glm::vec3 QuadTreeNode::getNormal(glm::vec3 iPt) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return iPt;
}*/

/*void QuadTreeNode::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - rad, position[1] - rad, position[2] - rad),
                         Eigen::Vector3f(position[0] + rad, position[1] + rad, position[2] + rad));
}*/

void QuadTreeNode::printObj() {
   printf("hello?\n");
   if (q1->type == 2) { printf("wut\n"); }
   q1->printObj();
   if (q2) q2->printObj();
   if (q3) q3->printObj();
   if (q4) q4->printObj();
}

BoundingBox QuadTreeNode::combineBB(BoundingBox* box1, BoundingBox* box2, BoundingBox* box3, BoundingBox* box4) {
   return BoundingBox(glm::vec3(fmin(fmin(fmin(box1->minPt[0], box2->minPt[0]), box3->minPt[0]), box4->minPt[0]),
                                fmin(fmin(fmin(box1->minPt[1], box2->minPt[1]), box3->minPt[1]), box4->minPt[1]),
                                fmin(fmin(fmin(box1->minPt[2], box2->minPt[2]), box3->minPt[2]), box4->minPt[2])),
                      glm::vec3(fmax(fmax(fmax(box1->maxPt[0], box2->maxPt[0]), box3->maxPt[0]), box4->maxPt[0]),
                                fmax(fmax(fmax(box1->maxPt[1], box2->maxPt[1]), box3->maxPt[1]), box4->maxPt[1]),
                                fmax(fmax(fmax(box1->maxPt[2], box2->maxPt[2]), box3->maxPt[2]), box4->maxPt[2])));
}

int QuadTreeNode::treeLength() {
   int length = 1;
   
   if (q1) {
      if (q1->type != 7) {
         length++;
      } else {
         length += static_cast<QuadTreeNode*>(q1)->treeLength();
      }
   }
   if (q2) {
      if (q2->type != 7) {
         length++;
      } else {
         length += static_cast<QuadTreeNode*>(q2)->treeLength();
      }
   }
   if (q3) {
      if (q3->type != 7) {
         length++;
      } else {
         length += static_cast<QuadTreeNode*>(q3)->treeLength();
      }
   }
   if (q4) {
      if (q4->type != 7) {
         length++;
      } else {
         length += static_cast<QuadTreeNode*>(q4)->treeLength();
      }
   }

   return length;
}

void QuadTreeNode::toSerialArray(Triangle *objectArray, int *currentIndex) {
   int i;
   int thisInd = *currentIndex;
   
   *currentIndex += 1;
   
   if (q1) {
      indeces[0] = *currentIndex;
      if (q1->type != 7) {
         assert(q1->type == 2);
         memcpy(objectArray + (*currentIndex), q1, sizeof(Triangle));
         *currentIndex += 1;
      } else {
         reinterpret_cast<QuadTreeNode*>(q1)->toSerialArray(objectArray, currentIndex);
      }
   }
   if (q2) {
      indeces[1] = *currentIndex;
      if (q2->type != 7) {
         assert(q2->type == 2);
         memcpy(objectArray + (*currentIndex), q2, sizeof(Triangle));
         *currentIndex += 1;
      } else {
         reinterpret_cast<QuadTreeNode*>(q2)->toSerialArray(objectArray, currentIndex);
      }
   }
   if (q3) {
      indeces[2] = *currentIndex;
      if (q3->type != 7) {
         assert(q3->type == 2);
         memcpy(objectArray + (*currentIndex), q3, sizeof(Triangle));
         *currentIndex += 1;
      } else {
         reinterpret_cast<QuadTreeNode*>(q3)->toSerialArray(objectArray, currentIndex);
      }
   }
   if (q4) {
      indeces[3] = *currentIndex;
      if (q4->type != 7) {
         assert(q4->type == 2);
         memcpy(objectArray + (*currentIndex), q4, sizeof(Triangle));
         *currentIndex += 1;
      } else {
         reinterpret_cast<QuadTreeNode*>(q4)->toSerialArray(objectArray, currentIndex);
      }
   }
   //printf("%d\n", *currentIndex);
   //Put the current node into the array at the end
   //if (thisInd >= 217450) printf("BAD ERROR ABORT\n");
   memcpy(objectArray + thisInd, this, sizeof(QuadTreeNode));
   //printf("%p\n", (objectArray + thisInd));
}
