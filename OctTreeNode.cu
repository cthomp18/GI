/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "OctTreeNode.h"

#define TOLERANCE 0.001

using namespace std;

int sortAxisOct = 0;

bool sorterOct(SceneObject* s1, SceneObject* s2) { 
   if (sortAxisOct == 0) {
      return s1->boundingBox.middle.x < s2->boundingBox.middle.x;
   } else if (sortAxisOct == 1) {
      return s1->boundingBox.middle.y < s2->boundingBox.middle.y;
   } else if (sortAxisOct == 2) {
      return s1->boundingBox.middle.z < s2->boundingBox.middle.z;
   } else {
      std::cout << "fuck" << std::endl;
      return false; //fuck
   }
}

OctTreeNode::OctTreeNode(std::vector<SceneObject*> objects, int n, int depth) : SceneObject() {
   
   int middle, quarter, curInd = 0;
   uint octer;
   std::vector<SceneObject*> tempVect1, tempVect2, tempVect3;
   std::vector<SceneObject*> objs;
   std::vector<BoundingBox*> bbs;
   
   //SceneObject *hitObj = NULL;

   objs.clear();
   bbs.clear();
   if (!depth) { cout << "right " << sizeof(OctTreeNode) << endl; }
   for (int i = 0; i < 8; i++) {
   if (!depth && i == 7) cout << "which" << endl;
      octants[i] = NULL;
      if (!depth && i == 7) cout << "line" << endl;
      indeces[i] = -1;
      if (!depth && i == 7) cout << "dawg" << endl;
      objs.push_back(NULL);
   }
   if (!depth) { cout << "here" << endl; }
   /*std::cout << "Depth: " << depth << std::endl;
   for (int i = 0; i < objects.size(); i++) {
      objects[i]->printObj();
   }*/
   
   if (n <= 8) {
      //cout << n << endl;
      for (int i = 0; i < 8; i++) {
         if (i + 1 <= n) octants[i] = objs[i] = objects[i];
      }
      
      for (int i = 0; i < n; i++) {
         bbs.push_back(&(objs[i]->boundingBox));
      }
      
      boundingBox = combineBB(bbs);
   } else {      
      //std::cout << sortAxis << std::endl;
      //cout << n << endl;
      sortAxisOct = 0;
      std::sort(objects.begin(), objects.end(), sorterOct);
      sortAxisOct = 1;
      
      /*std::cout << "---------------New Recurse---------------------" << std::endl;
      std::cout << "SortAxis: " << sortAxis << std::endl;
      for (int i = 0; i < n; i++) {
         std::cout << objects[i]->boundingBox->middle.x() << " " << objects[i]->boundingBox->middle.y() << " " << objects[i]->boundingBox->middle.z() << std::endl;
      }*/
      
      middle = n / 2;
      quarter = middle / 2;
      octer = quarter / 2;
      
      tempVect1.clear();
      for (int i = 0; i < middle; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterOct);
      sortAxisOct = 2;
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      
      tempVect3.clear();
      for (uint i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      tempVect3.clear();
      for (uint i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      tempVect2.clear();
      for (uint i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      sortAxisOct = 1;
      
      tempVect3.clear();
      for (uint i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      tempVect3.clear();
      for (uint i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      
      tempVect1.clear();
      for (int i = middle; i < n; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterOct);
      sortAxisOct = 2;
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      
      tempVect3.clear();
      for (uint i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      tempVect3.clear();
      for (uint i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
            
      tempVect2.clear();
      for (uint i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      
      tempVect3.clear();
      for (uint i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      tempVect3.clear();
      for (uint i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants[curInd++] = new OctTreeNode(tempVect3, tempVect3.size(), depth + 1);
      
      for (int i = 0; i < curInd; i++) {
         bbs.push_back(&(octants[i]->boundingBox));
      }
      boundingBox = combineBB(bbs);
   }
   type = 8;
   checkCollision = (&checkOctTreeCollision);
   getNormal = (&getOctTreeNormal);
}

OctTreeNode::OctTreeNode(OctTreeNode* o) {
   int i;
   for (i = 0; i < 8; i++) {
      octants[i] = o->octants[i];
      indeces[i] = o->indeces[i];
   }
   copyData(o);
   checkCollision = (&checkOctTreeCollision);
   getNormal = (&getOctTreeNormal);
}

OctTreeNode::OctTreeNode() : SceneObject() {
   type = 8;
   //typedef float SceneObject::* fPtr;
   //checkCollision = static_cast<float (SceneObject::*)>(&OctTreeNode::collision);
   checkCollision = (&checkOctTreeCollision);
   getNormal = (&getOctTreeNormal);
}
OctTreeNode::~OctTreeNode() {
   int i;
   //printf("a suh dude\n");
   for (i = 0; i < 8; i++) {
      if (octants[i]) {
         delete octants[i];
      }
   }
}

/*float OctTreeNode::checkCollision2(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
printf("otree collision\n");
return -1.0f;
   /*printf("pls\n");
   glm::vec4 startTransform;
   float t, tempT;
   SceneObject* tempObj;
   t = tempT = -1.0f;
   
   printf("Wanted to make sure\n");

  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (boundingBox.checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   
   if (octants[0]->transformed) {
      t = octants[0]->checkCollision(glm::vec3(octants[0]->transform * startTransform), glm::mat3(octants[0]->transform) * ray, time, &tempObj);
   } else {
      t = octants[0]->checkCollision(start, ray, time, &tempObj);
   }
   *object = tempObj;

   for (int i = 1; i < 8; i++) {
      if (octants[i]) {
         if (t >= TOLERANCE) {
            tempT = octants[i]->boundingBox.checkCollision(start, ray, time);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  tempT = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
               } else {
                  tempT = octants[i]->checkCollision(start, ray, time, &tempObj);
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = tempObj;
               }
            }
         } else {
            t = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
            *object = tempObj;
         }
      } //else break();
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;*/
//}
/*float OctTreeNode::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   return -1.0f;
}*/

SceneObject* OctTreeNode::getObj() {
   return NULL;
}

/*float OctTreeNode::checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
//printf("%f %f %f\n", start.x, start.y, start.z);
//printf("%f %f %f\n", ray.x, ray.y, ray.z);
printf("otree collision\n");
//return -1.0f;
   //printf("pls\n");
   glm::vec4 startTransform;
   float t, tempT;
   //int i;
   SceneObject* tempObj;
   t = tempT = -1.0f;
   
   //printf("Wanted to make sure\n");

   //if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   //if (this == NULL) printf("Seriously what the fuck\n");
   printf("CURRENT MEM: %p\n", this);
   int pf = printf("Type? %d\n", this->type);
   printf("%d\n", pf);
   printf("blah? %d\n", this->blahblah);
   printf("amb? %f\n", this->ambient);
   printf("is it here?\n");
   if (boundingBox.checkCollision(start, ray, time) < TOLERANCE) { printf("bb not hit\n"); return -1.0f; }
   printf("nope\n");
   if (octants[0] == NULL) {
      printf("roll up in the club\n");
   } else {
      printf("like i got a fat...\n");
   }
   if (octants[0]) {
   if (octants[0]->transformed) {
      t = octants[0]->checkCollision(glm::vec3(octants[0]->transform * startTransform), glm::mat3(octants[0]->transform) * ray, time, &tempObj);
   } else {
      pf = printf("Type octant? %d\n", octants[0]->type);
      printf("%d\n", pf);
      printf("BLAH octant? %d\n", octants[0]->blahblah);
      printf("AMBi octant? %f\n", octants[0]->ambient);
      
      printf("OCTANT MEM: %p\n", &(this->octants[0]));
      octants[0]->type = 8;
      octants[0]->blahblah = 1;
      octants[0]->ambient = 4.0f;
      t = octants[0]->checkCollision(start, ray, time, &tempObj);
   }
   }
   *object = tempObj;
   printf("t: %f\n", t);
   printf("Type? %d\n", this->type);
   if (this->octants[1]) {
      printf("anything, really\n");
   } else {
      printf("pls\n");
   }
   printf("looking for something\n");
   
   int i = 0;
   for (i = 1; i < 8; i++) {
      printf("please\n");
      if (octants[i]) {
      printf("yo\n");
         if (t >= 0.001) {
            printf("hi\n");
            tempT = octants[i]->boundingBox.checkCollision(start, ray, time);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  tempT = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
               } else {
                  printf("yo dawg\n");
                  if (octants[i]->type != 8) {
                     printf("triangle starting\n");
                  }
                  tempT = octants[i]->checkCollision(start, ray, time, &tempObj);
                  printf("k\n");
                  if (octants[i]->type != 8) {
                     printf("triangle ending\n");
                  }
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = tempObj;
               }
            }
         } else {
            t = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &tempObj);
            *object = tempObj;
         }
      } //else break();
      printf("sup fam\n");
   }
   printf("whats happening\n");
   if (t < TOLERANCE) {
      *object = NULL;
   }
   
   return t;
}*/

/*CUDA_CALLABLE glm::vec3 OctTreeNode::getNormal(glm::vec3 iPt) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   printf("the fuck\n");
   return glm::vec3(0.0f, 0.0f, 0.0f);
}*/

/*void OctTreeNode::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - rad, position[1] - rad, position[2] - rad),
                         Eigen::Vector3f(position[0] + rad, position[1] + rad, position[2] + rad));
}*/

void OctTreeNode::printObj() {
   for (int i = 0; i < 8; i++) {
      if (octants[i]) octants[i]->printObj();
   }
}

BoundingBox OctTreeNode::combineBB(std::vector<BoundingBox*> boxes) {
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

int OctTreeNode::treeLength() {
   int length = 1;
   
   for (int i = 0; i < 8; i++) {
      if (octants[i]) {
         if (octants[i]->type != 8) {
            length++;
         } else {
            length += static_cast<OctTreeNode*>(octants[i])->treeLength();
         }
      }
   }
   
   return length;
}

/*
This is done to transfer over most, if not all, objects into the GPU for CUDA.
Each node keeps track of its children through the indeces within the list.
The root node, once on the card, should be the very first element.
*/
void OctTreeNode::toSerialArray(Triangle* objectArray, int* currentIndex) {
   int i;
   int thisInd = *currentIndex;
   
   *currentIndex += 1;
   
   for (i = 0; i < 8; i++) {
      if (octants[i]) {
         indeces[i] = *currentIndex;
         if (octants[i]->type != 8) {
            if (*currentIndex >= 217450) printf("BAD ERROR ABORT\n");
            //printf("TYPE BURH: %d\n", octants[i]->type);
            assert(octants[i]->type == 2);
            memcpy(objectArray + (*currentIndex), octants[i], sizeof(Triangle));
            //printf("%p\n", (objectArray + (*currentIndex)));
            *currentIndex += 1;
         } else {
            reinterpret_cast<OctTreeNode*>(octants[i])->toSerialArray(objectArray, currentIndex);
         }
         //delete(octants[i]);
         //octants[i] = NULL;
      }
   }
   //printf("%d\n", *currentIndex);
   //Put the current node into the array at the end
   if (thisInd >= 217450) printf("BAD ERROR ABORT\n");
   memcpy(objectArray + thisInd, this, sizeof(OctTreeNode));
   //printf("%p\n", (objectArray + thisInd));
}
