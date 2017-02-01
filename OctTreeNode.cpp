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
      return s1->boundingBox->middle.x < s2->boundingBox->middle.x;
   } else if (sortAxisOct == 1) {
      return s1->boundingBox->middle.y < s2->boundingBox->middle.y;
   } else if (sortAxisOct == 2) {
      return s1->boundingBox->middle.z < s2->boundingBox->middle.z;
   } else {
      std::cout << "fuck" << std::endl;
      return false; //fuck
   }
}

OctTreeNode::OctTreeNode(std::vector<SceneObject*> objects, int n, int depth) : SceneObject() {
   int middle, quarter, octer;
   std::vector<SceneObject*> tempVect1, tempVect2, tempVect3;
   std::vector<SceneObject*> objs;
   std::vector<Box*> bbs;
   
   SceneObject *hitObj = NULL;
   
   octants.clear();
   objs.clear();
   bbs.clear();
   for (int i = 0; i < 8; i++) {
      octants.push_back(NULL);
      objs.push_back(NULL);
   }
   
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
         bbs.push_back(objs[i]->boundingBox);
      }
      
      boundingBox = combineBB(bbs);
   } else {      
      //std::cout << sortAxis << std::endl;
      //cout << n << endl;
      octants.clear();
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
      for (int i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect3.clear();
      for (int i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect2.clear();
      for (int i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      sortAxisOct = 1;
      
      tempVect3.clear();
      for (int i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect3.clear();
      for (int i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect1.clear();
      for (int i = middle; i < n; i++) tempVect1.push_back(objects[i]);
      std::sort(tempVect1.begin(), tempVect1.end(), sorterOct);
      sortAxisOct = 2;
      
      tempVect2.clear();
      for (int i = 0; i < quarter; i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      
      tempVect3.clear();
      for (int i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect3.clear();
      for (int i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
            
      tempVect2.clear();
      for (int i = quarter; i < tempVect1.size(); i++) tempVect2.push_back(tempVect1[i]);
      std::sort(tempVect2.begin(), tempVect2.end(), sorterOct);
      
      tempVect3.clear();
      for (int i = 0; i < octer; i++) tempVect3.push_back(tempVect2[i]);
      if (octer) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      tempVect3.clear();
      for (int i = octer; i < tempVect2.size(); i++) tempVect3.push_back(tempVect2[i]);
      if (octer != tempVect2.size()) octants.push_back(new OctTreeNode(tempVect3, tempVect3.size(), depth + 1));
      
      for (int i = 0; i < octants.size(); i++) {
         bbs.push_back(octants[i]->boundingBox);
      }
      boundingBox = combineBB(bbs);
   }
   type = 8;
}

OctTreeNode::OctTreeNode() : SceneObject() {}
OctTreeNode::~OctTreeNode() {}

float OctTreeNode::checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   glm::vec4 startTransform;
   float t, tempT;
   std::vector<SceneObject*> objs;
   objs.resize(8);
   t = tempT = -1.0f;
   //hitObj = NULL;
   
  // if (boundingBox == NULL) std::cout << "it's null!" << std::endl;
   startTransform = glm::vec4(start, 1.0f);
   if (boundingBox->checkCollision(start, ray, time) < TOLERANCE) return -1.0f;
   
   if (octants[0]->transformed) {
      t = octants[0]->checkCollision(glm::vec3(octants[0]->transform * startTransform), glm::mat3(octants[0]->transform) * ray, time, &objs[0]);
   } else {
      t = octants[0]->checkCollision(start, ray, time, &objs[0]);
   }
   *object = objs[0];

   for (int i = 1; i < 8; i++) {
      if (octants[i]) {
         if (t >= TOLERANCE) {
            tempT = octants[i]->boundingBox->checkCollision(start, ray, time);
            if (tempT >= TOLERANCE && tempT < t) {
               if (octants[i]->transformed) {
                  tempT = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &objs[i]);
               } else {
                  tempT = octants[i]->checkCollision(start, ray, time, &objs[i]);
               }
               if (tempT >= TOLERANCE && tempT < t) {
                  t = tempT;
                  *object = objs[i];
               }
            }
         } else {
            t = octants[i]->checkCollision(glm::vec3(octants[i]->transform * startTransform), glm::mat3(octants[i]->transform) * ray, time, &objs[i]);
            *object = objs[i];
         }
      } //else break();
   }
   
   if (t < TOLERANCE) {
      *object = NULL;
   }
   //left->hitObj = NULL;
   //if (right) right->hitObj = NULL;
   
   return t;
}

glm::vec3 OctTreeNode::getNormal(glm::vec3 iPt) {
   //std::cout << "Oh no! I fucked up!" << std::endl;
   return glm::vec3(0.0f, 0.0f, 0.0f);
}

SceneObject* OctTreeNode::getObj() {
   return hitObj;
}


/*void OctTreeNode::constructBB() {
   boundingBox = new Box(Eigen::Vector3f(position[0] - rad, position[1] - rad, position[2] - rad),
                         Eigen::Vector3f(position[0] + rad, position[1] + rad, position[2] + rad));
}*/

void OctTreeNode::printObj() {
   for (int i = 0; i < 8; i++) {
      if (octants[i]) octants[i]->printObj();
   }
}

Box* OctTreeNode::combineBB(std::vector<Box*> boxes) {
   float xmin = boxes[0]->minPt[0], ymin = boxes[0]->minPt[1], zmin = boxes[0]->minPt[2];
   float xmax = boxes[0]->maxPt[0], ymax = boxes[0]->maxPt[1], zmax = boxes[0]->maxPt[2];
   for (int i = 1; i < boxes.size(); i++) {
      xmin = fmin(xmin, boxes[i]->minPt[0]);
      ymin = fmin(ymin, boxes[i]->minPt[1]);
      zmin = fmin(zmin, boxes[i]->minPt[2]);
      xmax = fmax(xmax, boxes[i]->maxPt[0]);
      ymax = fmax(ymax, boxes[i]->maxPt[1]);
      zmax = fmax(zmax, boxes[i]->maxPt[2]);
   }
   return new Box(glm::vec3(xmin, ymin, zmin), glm::vec3(xmax, ymax, zmax));
}
