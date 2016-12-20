/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
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
      
      glm::vec4 pigment;
      glm::vec3 translateVector;
      glm::vec3 rotateVector;
      glm::vec3 scaleVector;
      glm::mat4 transform;
      
      float ambient;
      float diffuse;
      float specular;
      float roughness;
      float reflection;
      float refraction;
      float indexRefraction;
      float photonReflectance;
      float photonRefractance;
      float dropoff;
      
      int type;
      
      Box* boundingBox;
      SceneObject* hitObj;
      void constructBB();
      bool transformed;
      virtual float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      virtual float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      virtual glm::vec3 getNormal(glm::vec3 iPt, float time);
      virtual SceneObject* getObj();
      
      void applyTransforms();
      
      virtual void printObj();
      
   private:
      void rotate();
      void scale();
      void translate();
};

#endif
