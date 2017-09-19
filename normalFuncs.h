#ifndef __NORMFUNS_H__
#define __NORMFUNS_H__

#include "glm/glm.hpp"
#include <iostream>
#include <float.h>
#include <math.h>
#include "cuda_helper.h"
#include "SceneObject.h"
#include "OctTreeNode.h"
#include "Triangle.h"
#include "Plane.h"
#include "BiTreeNode.h"
#include "Box.h"
#include "GerstnerWave.h"
#include "QuadTreeNode.h"
#include "Cone.h"
#include "Sphere.h"
#include "BoundingBox.h"

CUDA_CALLABLE glm::vec3 getOctTreeNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
//CUDA_CALLABLE glm::vec3 getOctTreeNormal2(SceneObject *thisObj, glm::vec3 iPt, float time);
CUDA_CALLABLE glm::vec3 getTriNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getPlaneNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getBiTreeNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getBoxNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
glm::vec3 getGWNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getConeNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getQuadTreeNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);
CUDA_CALLABLE glm::vec3 getSphereNormal(SceneObject *thisObj, glm::vec3 iPt, float *shF);

#endif
