/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include <vector>
#include <iostream>
#include <math.h>

#ifndef __SCENEOBJECT_H__
#define __SCENEOBJECT_H__

class Collision;
class Box;

class SceneObject {
   public:
      SceneObject();
      ~SceneObject();
      
      Eigen::Vector4f pigment;
      Eigen::Vector3f translateVector;
      Eigen::Vector3f rotateVector;
      Eigen::Vector3f scaleVector;
      Eigen::Matrix4f transform;
      
      float ambient;
      float diffuse;
      float specular;
      float roughness;
      float reflection;
      float refraction;
      float indexRefraction;
      float photonReflectance;
      float photonRefractance;
      
      int type;
      
      Box* boundingBox;
      SceneObject* hitObj;
      void constructBB();
      bool transformed;
      virtual float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time);
      virtual float checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time, SceneObject** object);
      virtual Eigen::Vector3f getNormal(Eigen::Vector3f iPt, float time);
      virtual SceneObject* getObj();
      
      void applyTransforms();
      
   private:
      void rotate();
      void scale();
      void translate();
};

#endif
