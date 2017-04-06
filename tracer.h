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

#include "cuda_helper.h"
#include "OctTreeNode.h"
#include "Triangle.h"
#include "Camera.h"
#include "RayTracer.h"
#include "structs.h"
#include "types.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp" //perspective, trans etc
#include "glm/gtc/type_ptr.hpp" //value_ptr
#include "glm/gtx/string_cast.hpp"

#define TILEWIDTH 16

// HandleError written by Chris Lupo

static void HandleError( cudaError_t err,
    const char *file,
    int line );
    
//TYPE* readFile(char* matrix);
//void MatrixMulOnDevice(TYPE *M, TYPE *N, TYPE *P, int width);
//void output(TYPE* newMat);
__global__ void toOctTree(Triangle *objectArray, int size, int gridDimension);
__global__ void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objsize, Pixel *pixelsD, Camera cam, int width, int height, RayTracer rt);
void RayTraceOnDevice(int width, int height, Pixel *pixels, std::vector<SceneObject*> objects, Camera *cam);

#endif