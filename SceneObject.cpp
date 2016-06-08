/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "SceneObject.h"
#include "Collision.h"
#include "Box.h"

SceneObject::SceneObject() {
   pigment = Eigen::Vector4f (-1.0, -1.0, -1.0, 0.0);
   translateVector = Eigen::Vector3f (0.0, 0.0, 0.0);
   rotateVector = Eigen::Vector3f (0.0, 0.0, 0.0);
   scaleVector = Eigen::Vector3f (1.0, 1.0, 1.0);
   transform = Eigen::Matrix4f::Identity();
   
   ambient = 0.1f;
   diffuse = 0.6f;
   specular = 0.0f;
   roughness = 0.05f;
   reflection = 0.0f;
   refraction = 0.0f;
   indexRefraction = 1.0f;
   photonReflectance = 0.5;
   photonRefractance = 0.0;
   
   type = -1;
   hitObj = NULL;
   boundingBox = NULL;
   transformed = false;
}

SceneObject::~SceneObject() {}

float SceneObject::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   std::cout << "parent call" << std::endl;
   return -1.0f;
}

float SceneObject::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object) {
   //std::cout << "parent call" << std::endl;
   *object = this;
   return checkCollision(start, ray, time);
}

Eigen::Vector3f SceneObject::getNormal(Eigen::Vector3f iPt, float time) {
   return Eigen::Vector3f(-1.0f, -1.0f, -1.0f);
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
      Eigen::Vector2f x = Eigen::Vector2f(boundingBox->minPt[0], boundingBox->maxPt[0]),
                      y = Eigen::Vector2f(boundingBox->minPt[1], boundingBox->maxPt[1]),
                      z = Eigen::Vector2f(boundingBox->minPt[2], boundingBox->maxPt[2]);
      Eigen::Vector3f bmin = boundingBox->minPt, bmax = boundingBox->maxPt;
      std::vector<Eigen::Vector3f> bbpts;
      bbpts.clear();
      /*for (int i = 0; i < 2; i++) {
         for (int j = 0; j < 2; j++) {
            for (int k = 0; k < 2; k++) {
               bbpts.push_back((transform * Eigen::Vector4f(x[i], y[j], z[k], 1.0f)).segment<3>(0));
            }
         }
      }*/
      bbpts.push_back(Eigen::Vector3f(bmin.x(), bmin.y(), bmin.z()));
      bbpts.push_back(Eigen::Vector3f(bmin.x(), bmin.y(), bmax.z()));
      bbpts.push_back(Eigen::Vector3f(bmin.x(), bmax.y(), bmin.z()));
      bbpts.push_back(Eigen::Vector3f(bmin.x(), bmax.y(), bmax.z()));
      bbpts.push_back(Eigen::Vector3f(bmax.x(), bmin.y(), bmin.z()));
      bbpts.push_back(Eigen::Vector3f(bmax.x(), bmin.y(), bmax.z()));
      bbpts.push_back(Eigen::Vector3f(bmax.x(), bmax.y(), bmin.z()));
      bbpts.push_back(Eigen::Vector3f(bmax.x(), bmax.y(), bmax.z()));
      //std::cout << "NEW_______________________________" << std::endl;
      for (int i = 0; i < bbpts.size(); i++) {
         //std::cout << bbpts[i].x() << " " << bbpts[i].y() << " " << bbpts[i].z() << std::endl;
         bbpts[i] = (transform * Eigen::Vector4f(bbpts[i].x(), bbpts[i].y(), bbpts[i].z(), 1.0f)).segment<3>(0);
         //std::cout << bbpts[i].x() << " " << bbpts[i].y() << " " << bbpts[i].z() << std::endl;
      }
      
      //std::cout << transform << std::endl;
      /*std::cout << "NEW_______________________________" << std::endl;
      std::cout << minx << " " << miny << " " << minz << std::endl;
      std::cout << maxx << " " << maxy << " " << maxz << std::endl;*/
      delete(boundingBox);
      for (int i = 0; i < bbpts.size(); i++) {
         if (bbpts[i].x() < minx) minx = bbpts[i].x();
         if (bbpts[i].x() > maxx) maxx = bbpts[i].x();
         if (bbpts[i].y() < miny) miny = bbpts[i].y();
         if (bbpts[i].y() > maxy) maxy = bbpts[i].y();
         if (bbpts[i].z() < minz) minz = bbpts[i].z();
         if (bbpts[i].z() > maxz) maxz = bbpts[i].z();
      }
      /*std::cout << "NEW_______________________________" << std::endl;
      std::cout << bmin.x() << " " << bmin.y() << " " << bmin.z() << std::endl;
      std::cout << bmax.x() << " " << bmax.y() << " " << bmax.z() << std::endl;
      std::cout << minx << " " << miny << " " << minz << std::endl;
      std::cout << maxx << " " << maxy << " " << maxz << std::endl;*/
      
      boundingBox = new Box(Eigen::Vector3f(minx, miny, minz), Eigen::Vector3f(maxx, maxy, maxz));
      //std::cout << transform << std::endl;
      //std::cout << boundingBox->middle << std::endl;
   } else {
      //std::cout << "BB NULL! " << type << std::endl;
   }
   
   transform = transform.inverse().eval();
}

void SceneObject::scale() {
   Eigen::Matrix4f scaleMat = Eigen::Matrix4f::Identity();
   for (int i = 0; i < 3; i++) scaleMat(i,i) = scaleVector[i];
   transform = scaleMat * transform;
   transformed = true;
}

void SceneObject::rotate() {
   Eigen::Matrix2f miniRotMat;
   Eigen::Matrix4f rotMat;
   float ang;
   for (int i = 0; i < 3; i++) {
      rotMat = Eigen::Matrix4f::Identity();
      if (fabs(ang = (rotateVector[i] * M_PI / 180.0f)) > 0.001f) {
         miniRotMat << cos(ang), -sin(ang), sin(ang), cos(ang);
         switch (i) {
            case 0 :
               rotMat.block<2,2>(1,1) = miniRotMat;
               break;
            case 1 :
               rotMat(0,0) = miniRotMat(0,0);
               rotMat(0,2) = miniRotMat(1,0); //REMEMBER: MINUS REVERSED FOR Y
               rotMat(2,0) = miniRotMat(0,1); // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
               rotMat(2,2) = miniRotMat(1,1);
               break;
            case 2 :
               rotMat.block<2,2>(0,0) = miniRotMat;
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
   Eigen::Matrix4f transMat = Eigen::Matrix4f::Identity();
   for (int i = 0; i < 3; i++) transMat(i,3) = translateVector[i];
   transform = transMat * transform;
   transformed = true;
}

void SceneObject::constructBB() {
   //std::cout << "Parent Call To CBB" << std::endl;
}
