/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#ifndef __SCENEOBJECT_H__
#define __SCENEOBJECT_H__

#include "cuda_helper.h"
#include "glm/glm.hpp"
#include "BoundingBox.h"
#include "Collision.h"
#include <vector>
#include <iostream>
#include <math.h>

class Collision;

class SceneObject {
   public:
      //typedef float SceneObject::* functionPtr;
      
      CUDA_CALLABLE SceneObject();
      CUDA_CALLABLE virtual ~SceneObject();
      
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
      int blahblah;
      
      //float (*checkCollision) (SceneObject *thisObj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      float (*checkCollision) (SceneObject *thisObj, glm::vec3 ray, SceneObject** object, int *shI, float *shF);
      glm::vec3 (*getNormal) (SceneObject *thisObj, glm::vec3 iPt, float *shF);
      
      BoundingBox boundingBox;
      //SceneObject* hitObj;
      void constructBB();
      bool transformed;
      //CUDA_CALLABLE virtual float checkCollision(glm::vec3 start, glm::vec3 ray, float time);
      //CUDA_CALLABLE virtual float checkCollision(glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
      //CUDA_CALLABLE virtual glm::vec3 getNormal(glm::vec3 iPt, float time);
      virtual SceneObject* getObj();
      
      void applyTransforms();
      
      CUDA_CALLABLE virtual void printObj();
      CUDA_CALLABLE void copyData(SceneObject *o);
      
   private:
      void rotate();
      void scale();
      void translate();
};

#endif
