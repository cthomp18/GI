/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "SceneObject.h"
#include "Collision.h"
#include "Box.h"

SceneObject::SceneObject() {
   pigment = glm::vec4 (-1.0f, -1.0f, -1.0f, 0.0f);
   translateVector = glm::vec3 (0.0f, 0.0f, 0.0f);
   rotateVector = glm::vec3 (0.0f, 0.0f, 0.0f);
   scaleVector = glm::vec3 (1.0f, 1.0f, 1.0f);
   transform = glm::mat4(1.0f);
   
   ambient = 0.1f;
   diffuse = 0.6f;
   specular = 0.0f;
   roughness = 0.05f;
   reflection = 0.0f;
   refraction = 0.0f;
   indexRefraction = 1.0f;
   photonReflectance = 0.5;
   photonRefractance = 0.0;
   dropoff = 1.0f;
   
   type = -1;
   hitObj = NULL;
   boundingBox = NULL;
   transformed = false;
}

SceneObject::~SceneObject() {}

float SceneObject::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   std::cout << "parent call" << std::endl;
   return -1.0f;
}

float SceneObject::checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object) {
   //std::cout << "parent call" << std::endl;
   *object = this;
   return checkCollision(start, ray, time);
}

glm::vec3 SceneObject::getNormal(glm::vec3 iPt, float time) {
   return glm::vec3(-1.0f, -1.0f, -1.0f);
}

SceneObject* SceneObject::getObj() {
   return this;
}

void SceneObject::applyTransforms() {
   scale();
   rotate();
   translate();
   
   //Manipulate Bounding Box
   if (boundingBox != NULL) {
      float minx, maxx, miny, maxy, minz, maxz;
      minx = miny = minz = FLT_MAX;
      maxx = maxy = maxz = -FLT_MAX;
      glm::vec2 x = glm::vec2(boundingBox->minPt[0], boundingBox->maxPt[0]),
                y = glm::vec2(boundingBox->minPt[1], boundingBox->maxPt[1]),
                z = glm::vec2(boundingBox->minPt[2], boundingBox->maxPt[2]);
      glm::vec3 bmin = boundingBox->minPt, bmax = boundingBox->maxPt;
      std::vector<glm::vec3> bbpts;
      bbpts.clear();
      /*for (int i = 0; i < 2; i++) {
         for (int j = 0; j < 2; j++) {
            for (int k = 0; k < 2; k++) {
               bbpts.push_back((transform * Eigen::Vector4f(x[i], y[j], z[k], 1.0f)).segment<3>(0));
            }
         }
      }*/
      bbpts.push_back(glm::vec3(bmin.x, bmin.y, bmin.z));
      bbpts.push_back(glm::vec3(bmin.x, bmin.y, bmax.z));
      bbpts.push_back(glm::vec3(bmin.x, bmax.y, bmin.z));
      bbpts.push_back(glm::vec3(bmin.x, bmax.y, bmax.z));
      bbpts.push_back(glm::vec3(bmax.x, bmin.y, bmin.z));
      bbpts.push_back(glm::vec3(bmax.x, bmin.y, bmax.z));
      bbpts.push_back(glm::vec3(bmax.x, bmax.y, bmin.z));
      bbpts.push_back(glm::vec3(bmax.x, bmax.y, bmax.z));
      //std::cout << "NEW_______________________________" << std::endl;
      for (int i = 0; i < bbpts.size(); i++) {
         //std::cout << bbpts[i].x() << " " << bbpts[i].y() << " " << bbpts[i].z() << std::endl;
         bbpts[i] = glm::vec3(transform * glm::vec4(bbpts[i].x, bbpts[i].y, bbpts[i].z, 1.0f));
         //std::cout << bbpts[i].x() << " " << bbpts[i].y() << " " << bbpts[i].z() << std::endl;
      }
      
      //std::cout << transform << std::endl;
      /*std::cout << "NEW_______________________________" << std::endl;
      std::cout << minx << " " << miny << " " << minz << std::endl;
      std::cout << maxx << " " << maxy << " " << maxz << std::endl;*/
      delete(boundingBox);
      for (int i = 0; i < bbpts.size(); i++) {
         if (bbpts[i].x < minx) minx = bbpts[i].x;
         if (bbpts[i].x > maxx) maxx = bbpts[i].x;
         if (bbpts[i].y < miny) miny = bbpts[i].y;
         if (bbpts[i].y > maxy) maxy = bbpts[i].y;
         if (bbpts[i].z < minz) minz = bbpts[i].z;
         if (bbpts[i].z > maxz) maxz = bbpts[i].z;
      }
      /*std::cout << "NEW_______________________________" << std::endl;
      std::cout << bmin.x() << " " << bmin.y() << " " << bmin.z() << std::endl;
      std::cout << bmax.x() << " " << bmax.y() << " " << bmax.z() << std::endl;
      std::cout << minx << " " << miny << " " << minz << std::endl;
      std::cout << maxx << " " << maxy << " " << maxz << std::endl;*/
      
      boundingBox = new Box(glm::vec3(minx, miny, minz), glm::vec3(maxx, maxy, maxz));
      //std::cout << transform << std::endl;
      //std::cout << boundingBox->middle << std::endl;
   } else {
      //std::cout << "BB NULL! " << type << std::endl;
   }
   
   transform = glm::inverse(transform);
}

void SceneObject::scale() {
   glm::mat4 scaleMat = glm::mat4(1.0f);
   for (int i = 0; i < 3; i++) scaleMat[i][i] = scaleVector[i];
   transform = scaleMat * transform;
   transformed = true;
}

void SceneObject::rotate() {
   glm::mat2 miniRotMat;
   glm::mat4 rotMat;
   float ang;
   for (int i = 0; i < 3; i++) {
      rotMat = glm::mat4(1.0f);
      if (fabs(ang = (rotateVector[i] * M_PI / 180.0f)) > 0.001f) {
         miniRotMat = glm::mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
         switch (i) {
            case 0 :
               rotMat[1][1] = miniRotMat[0][0];
               rotMat[2][1] = miniRotMat[1][0];
               rotMat[1][2] = miniRotMat[0][1];
               rotMat[2][2] = miniRotMat[1][1];
               break;
            case 1 :
               rotMat[0][0] = miniRotMat[0][0];
               rotMat[0][2] = miniRotMat[1][0]; //REMEMBER: MINUS REVERSED FOR Y
               rotMat[2][0] = miniRotMat[0][1]; // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
               rotMat[2][2] = miniRotMat[1][1];
               break;
            case 2 :
               rotMat[0][0] = miniRotMat[0][0];
               rotMat[1][0] = miniRotMat[1][0];
               rotMat[0][1] = miniRotMat[0][1];
               rotMat[1][1] = miniRotMat[1][1];
               break;
            default :
               break;
         }
      }
      transform = rotMat * transform;
   }
   transformed = true;
}

void SceneObject::translate() {
   glm::mat4 transMat = glm::mat4(1.0f);
   for (int i = 0; i < 3; i++) transMat[3][i] = translateVector[i];
   transform = transMat * transform;
   transformed = true;
}

void SceneObject::constructBB() {
   //std::cout << "Parent Call To CBB" << std::endl;
}

void SceneObject::printObj() {
   std::cout << "huh" << std::endl;

}
