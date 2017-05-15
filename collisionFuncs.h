#ifndef __COLLFUNS_H__
#define __COLLFUNS_H__

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

CUDA_CALLABLE float checkOctTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
CUDA_CALLABLE float checkOctTreeCollision2(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
CUDA_CALLABLE float checkTriCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
CUDA_CALLABLE float checkPlaneCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);
CUDA_CALLABLE float checkBiTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject** object);
CUDA_CALLABLE float checkBoxCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);
CUDA_CALLABLE float checkGWCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);
CUDA_CALLABLE float checkConeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);
CUDA_CALLABLE float checkQuadTreeCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);
CUDA_CALLABLE float checkSphereCollision(SceneObject *obj, glm::vec3 start, glm::vec3 ray, float time, SceneObject **object);

#endif
