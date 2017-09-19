#ifndef __CUDA_TRACER_H__
#define __CUDA_TRACER_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>

#include "cuda_helper.h"
#include "OctTreeNode.h"
#include "QuadTreeNode.h"
#include "Triangle.h"
#include "Sphere.h"
#include "Box.h"
#include "Plane.h"
#include "Cone.h"
#include "Camera.h"
//#include "RayTracer.h"
#include "RayTracer.cuh"
//#include "KDTreeNode.h"
#include "KDTreeNode.cuh"
#include "structs.h"
#include "types.h"
#include "collisionFuncs.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp" //perspective, trans etc
#include "glm/gtc/type_ptr.hpp" //value_ptr
#include "glm/gtx/string_cast.hpp"

#define TILEWIDTH 32
#define MAX_THREADS_PER_BLOCK 1024
#define MIN_BLOCKS_PER_MP     2

// HandleError written by Chris Lupo

static void HandleError( cudaError_t err,
    const char *file,
    int line );
    
//TYPE* readFile(char* matrix);
//void MatrixMulOnDevice(TYPE *M, TYPE *N, TYPE *P, int width);
//void output(TYPE* newMat);
__global__ void toOctTree(Triangle *objectArray, int size, int gridDimension);
__global__ void toQuadTree(Triangle *objectArray, int size, int gridDimension);
__global__ void toKDTree(Photon *kdArray, int size, int gridDimension);
__global__ void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objsize, Pixel *pixelsD, Camera cam, int width, int height, RayTracer *rt); //, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons);
void RayTraceOnDevice(int width, int height, Pixel *pixels, std::vector<SceneObject*> objects, Camera *cam, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons, time_t *startTime);

#endif
