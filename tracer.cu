#include "tracer.h"
// http://stackoverflow.com/questions/3016077/how-to-spot-undefined-behavior
//Chris Lupo's error handling fuction/macro

__shared__ float sharedFloats[TILEWIDTH*TILEWIDTH * 9];
__shared__ int sharedInts[TILEWIDTH*TILEWIDTH * 3];


static void HandleError( cudaError_t err,
    const char *file,
    int line ) {
  if (err != cudaSuccess) {
    printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
        file, line );
    exit( EXIT_FAILURE );
  }
}

#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))

__global__ void editFuncPtrs(SceneObject *object) {
   if (object->type == 0) {         //SPHERE
      object->checkCollision = &(checkSphereCollision);
      object->getNormal = &(getSphereNormal);
   } else if (object->type == 1) {  //PLANE
      object->checkCollision = &(checkPlaneCollision);
      object->getNormal = &(getPlaneNormal);
   } else if (object->type == 2) {  //TRIANGLE
      object->checkCollision = &(checkTriCollision);
      object->getNormal = &(getTriNormal);
   } else if (object->type == 3) {  //BOX
      object->checkCollision = &(checkBoxCollision);
      object->getNormal = &(getBoxNormal);
   } else if (object->type == 4) {  //CONE
      object->checkCollision = &(checkConeCollision);
      object->getNormal = &(getConeNormal);
   }
}

__global__ void toOctTree(Triangle *objectArray, int size, int gridDimension) {
   //printf("xd\n");
   Triangle* tempT;
   OctTreeNode* tempO;
   
   int threadInd = (blockIdx.y * (gridDimension * TILEWIDTH) * TILEWIDTH) + (blockIdx.x * TILEWIDTH) +
                   (threadIdx.y * (gridDimension * TILEWIDTH)) + threadIdx.x;//blockIdx.x;//*TILEWIDTH + threadIdx.x;
   int i;

   if (threadInd == 0) { printf(":() %d\n", size); 
      printf("%f %f %f\n", objectArray->boundingBox.minPt.x, objectArray->boundingBox.minPt.y, objectArray->boundingBox.minPt.z);
      printf("%f %f %f\n", objectArray->boundingBox.maxPt.x, objectArray->boundingBox.maxPt.y, objectArray->boundingBox.maxPt.z);
   }
   if (threadInd == size - 1) { printf("UH SUH DUDE %d\n", size); }

   if (threadInd < size && threadInd >= 0) {
      if (objectArray[threadInd].type == 8) {
         tempO = reinterpret_cast<OctTreeNode*>(objectArray + threadInd);
         
         tempO->checkCollision = &(checkOctTreeCollision);
         tempO->getNormal = &(getOctTreeNormal);
         
         for (i = 0; i < 8; i++) {
            if (tempO->indeces[i] != -1) {
               tempO->octants[i] = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[i]);
            } else {
               tempO->octants[i] = NULL;
            }
         }
      } else {
         tempT = objectArray + threadInd;
         tempT->checkCollision = &(checkTriCollision);
         tempT->getNormal = &(getTriNormal);
      }
   } 
   
   __syncthreads();
}

__global__ void toQuadTree(Triangle *objectArray, int size, int gridDimension) {
   Triangle* tempT;
   QuadTreeNode* tempO;
   
   int threadInd = (blockIdx.y * (gridDimension * TILEWIDTH) * TILEWIDTH) + (blockIdx.x * TILEWIDTH) +
                   (threadIdx.y * (gridDimension * TILEWIDTH)) + threadIdx.x;
   int i;
   
   if (threadInd < size && threadInd >= 0) {
      if (objectArray[threadInd].type == 7) {
         tempO = reinterpret_cast<QuadTreeNode*>(objectArray + threadInd);
         
         tempO->checkCollision = &(checkQuadTreeCollision);
         tempO->getNormal = &(getQuadTreeNormal);

         for (i = 0; i < 4; i++) {
            if (tempO->indeces[i] != -1) {
               tempO->quadrants[i] = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[i]);
            } else {
               tempO->quadrants[i] = NULL;
            }
         }
      } else {
         tempT = objectArray + threadInd;
         
         tempT->checkCollision = &(checkTriCollision);
         tempT->getNormal = &(getTriNormal);
      }
   }
   __syncthreads();
}

__global__ void toKDTree(Photon *kdArray, int size, int gridDimension) {
   int row = blockIdx.y*TILEWIDTH + threadIdx.y;
   int col = blockIdx.x*TILEWIDTH + threadIdx.x;
   
   KDTreeNode* tempKD;
   
   int threadInd = (blockIdx.y * (gridDimension * TILEWIDTH) * TILEWIDTH) + (blockIdx.x * TILEWIDTH) +
                   (threadIdx.y * (gridDimension * TILEWIDTH)) + threadIdx.x;//blockIdx.x;//*TILEWIDTH + threadIdx.x;
   int i;

   if (threadInd < size && threadInd >= 0) {
      tempKD = reinterpret_cast<KDTreeNode*>(kdArray + (threadInd * 2));
      //tempO->checkCollision = &(checkOctTreeCollision);
      //tempO->getNormal = &(getOctTreeNormal);

      tempKD->photon = kdArray + (threadInd * 2) + 1;
      
      if (tempKD->leftInd != -1) {
         tempKD->left = reinterpret_cast<KDTreeNode*>(kdArray + tempKD->leftInd);
      } else {
         tempKD->left = NULL;
      }
      
      if (tempKD->rightInd != -1) {
         tempKD->right = reinterpret_cast<KDTreeNode*>(kdArray + tempKD->rightInd);
      } else {
         tempKD->right = NULL;
      }
   }
   __syncthreads();
}

__global__ __launch_bounds__( MAX_THREADS_PER_BLOCK, MIN_BLOCKS_PER_MP ) void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objSize, Pixel *pixelsD, Camera *camera, int width, int height, RayTracer *raytracer) {//, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons) {
//__global__ void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objSize, Pixel *pixelsD, Camera *camera, int width, int height, RayTracer *raytracer) {//, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons) {
   //__shared__ TYPE Mds[TILEWIDTH][TILEWIDTH];
   //__shared__ TYPE Nds[TILEWIDTH][TILEWIDTH];
   
   //extern __shared__ float sh[];
   //extern __shared__ float uh[];
   //float *sh = NULL;
   
   int row = blockIdx.y*TILEWIDTH + threadIdx.y;
   int col = blockIdx.x*TILEWIDTH + threadIdx.x;
   //int currentImgInd = row * width + col;
   int currentImgInd = col * height + row;
   
   int threadNum = (threadIdx.y * TILEWIDTH) + threadIdx.x;
   
   int threadSpotF = threadNum * 9;
   int threadSpotI = threadNum * 3;
   
   glm::vec3 cPos = camera->getPosition();
   Collision* collision;
   glm::vec3 ray, tempColor;
   
   ray = pixelsD[currentImgInd].pt;// - cPos;
   ray = glm::normalize(ray);

   sharedFloats[threadSpotF+6] = cPos.x;
   sharedFloats[threadSpotF+7] = cPos.y;
   sharedFloats[threadSpotF+8] = cPos.z;
   collision = raytracer->trace(ray, sharedInts + threadSpotI, sharedFloats + threadSpotF);

   if (collision->time > TOLERANCE) {
      pixelsD[currentImgInd].clr = raytracer->calcRadiance(cPos, cPos + ray * collision->time, collision->object, false, 1.0f, 1.33f, 0.95f, threadNum, 0, sharedInts + threadSpotI, sharedFloats + threadSpotF); //Cam must start in air
   }
   else {
      pixelsD[currentImgInd].clr = glm::vec3(1.0f, 1.0f, 1.0f);
   }
   delete(collision);

   __syncthreads();
}

// Set the card up to run cuda
void RayTraceOnDevice(int width, int height, Pixel *pixels, std::vector<SceneObject*> objects, Camera *cam, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons, time_t *startTime) {
   SceneObject** objArrD = NULL;
   SceneObject** objArrH = NULL;// = &objects[0];
   Photon* globalsD = NULL;
   Photon* causticsD = NULL;
   int gSize = 0;
   int cSize = 0;
   int* sizesH = NULL;
   int* sizesD = NULL;
   int gridDimension = 0;
   int depth;
      
   Triangle* tempOctTree = NULL;
   Photon* tempKDTree = NULL;
   Camera* cameraD = NULL;
   Pixel* pixelsD = NULL;
   RayTracer* raytracerD = NULL;
   RayTracer* raytracer = NULL;
   int tempSize = 0, tempInd = 0, pixelArrSize = 0;
   
   dim3 dimGrid = dim3(0,0);
   dim3 dimBlock = dim3(0,0);
   
   KDTreeNode **cudaPhotonStack;
   
   pixelArrSize = width * height * sizeof(Pixel);
   printf("~~~~~~~~~~~~~~FUNC LOC: %p\n", &checkOctTreeCollision);
   printf("Transferring Data...\n");
   printf("Size parray: %d\n", pixelArrSize);

   HANDLE_ERROR(cudaMalloc(&pixelsD, pixelArrSize));
   HANDLE_ERROR(cudaMemcpy(pixelsD, pixels, pixelArrSize, cudaMemcpyHostToDevice));
   HANDLE_ERROR(cudaMalloc(&cameraD, sizeof(Camera)));
   HANDLE_ERROR(cudaMemcpy(cameraD, cam, sizeof(Camera), cudaMemcpyHostToDevice));
   
   //Allocate memory for all needed object pointers and their relative sizes
   HANDLE_ERROR(cudaMalloc(&objArrD, objects.size() * sizeof(SceneObject*)));
   HANDLE_ERROR(cudaMalloc(&sizesD, objects.size() * sizeof(int)));
   
   //Allocate memory on host for device pointers and object sizes
   printf("suh\n");
   objArrH = (SceneObject**)malloc(objects.size() * sizeof(SceneObject*));
   printf("dud\n");
   sizesH = (int*)malloc(objects.size() * sizeof(int));
   printf("bruh\n");
   
   //printf("OBJ SIZE: %d\n", objects.size());
   printf("Objects...\n");
   for (uint i = 0; i < objects.size(); i++) {
      //printf("hello\n");
      if (objects[i]->type == 8) { //Oct tree handling
         //printf("yes\n");
         printf("OCT TREE START GPU\n");
         tempInd = 0; //yah
         //Get the proper size of the tree
         tempSize = static_cast<OctTreeNode*>(objects[i])->treeLength();
         sizesH[i] = tempSize;
         
         //Copy over array represenation of tree
         printf("TREE SIZE: %d\n", tempSize);
         
         
         tempOctTree = (Triangle*)calloc(tempSize, sizeof(Triangle));
         
         
         printf("ARR SIZE: %lu\n", tempSize * sizeof(Triangle));
         printf("ARR START POS: %p\n", tempOctTree);
         printf("frick\n");
         printf("SO SIZE %lu\n", sizeof(SceneObject));
         printf("TRI SIZE %lu\n", sizeof(Triangle));
         printf("OCT SIZE %lu\n", sizeof(OctTreeNode));
         
         
         reinterpret_cast<OctTreeNode*>(objects[i])->toSerialArray(tempOctTree, &tempInd);
         printf("BBS\n");
         printf("%f %f %f\n", objects[i]->boundingBox.minPt.x, objects[i]->boundingBox.minPt.y, objects[i]->boundingBox.minPt.z);
         printf("%f %f %f\n", objects[i]->boundingBox.maxPt.x, objects[i]->boundingBox.maxPt.y, objects[i]->boundingBox.maxPt.z);
         printf("%f %f %f\n", tempOctTree->boundingBox.minPt.x, tempOctTree->boundingBox.minPt.y, tempOctTree->boundingBox.minPt.z);
         printf("%f %f %f\n", tempOctTree->boundingBox.maxPt.x, tempOctTree->boundingBox.maxPt.y, tempOctTree->boundingBox.maxPt.z);
         
         printf("frack\n");
         
         HANDLE_ERROR(cudaMalloc(&(objArrH[i]), tempSize * sizeof(Triangle)));
         
         printf("whats\n");
         
         HANDLE_ERROR(cudaMemcpy(objArrH[i], tempOctTree, tempSize * sizeof(Triangle), cudaMemcpyHostToDevice));
         
         printf("that\n");
         
         free(tempOctTree);
         
         printf("OH FUCK\n");
         
         //Rebuild tree on device
         gridDimension = int(ceil(sqrt((float(tempSize)) / (float(TILEWIDTH * TILEWIDTH)))));
         printf("GD: %d\n", gridDimension);
         dimGrid = dim3(gridDimension, gridDimension);//dim3((tempSize / TILEWIDTH) + 1, 1);
         dimBlock = dim3(TILEWIDTH,TILEWIDTH);//dim3(TILEWIDTH, 1);
         //printf("kk\n");
         
         
         HANDLE_ERROR(cudaPeekAtLastError());
         HANDLE_ERROR(cudaDeviceSynchronize());
         
         
         toOctTree<<<dimGrid, dimBlock>>>((Triangle*)(objArrH[i]), tempSize, gridDimension);
         
         
         //printf("kkk\n");
         HANDLE_ERROR(cudaPeekAtLastError());
         HANDLE_ERROR(cudaDeviceSynchronize());
   
      } else if (objects[i]->type == 7) { //Quad tree handling (Gerstner Wave Triangles)
         //printf("yes\n");
         printf("QUAD TREE START GPU\n");
         tempInd = 0; //yah
         //Get the proper size of the tree
         tempSize = static_cast<QuadTreeNode*>(objects[i])->treeLength();
         sizesH[i] = tempSize;
         
         //Copy over array represenation of tree
         printf("TREE SIZE: %d\n", tempSize);
         
         
         tempOctTree = (Triangle*)calloc(tempSize, sizeof(Triangle));
         
         
         printf("ARR SIZE: %lu\n", tempSize * sizeof(Triangle));
         printf("ARR START POS: %p\n", tempOctTree);
         printf("frick\n");
         printf("SO SIZE %lu\n", sizeof(SceneObject));
         printf("TRI SIZE %lu\n", sizeof(Triangle));
         printf("Quad SIZE %lu\n", sizeof(QuadTreeNode));
         
         
         reinterpret_cast<QuadTreeNode*>(objects[i])->toSerialArray(tempOctTree, &tempInd);
         printf("BBS\n");
         printf("%f %f %f\n", objects[i]->boundingBox.minPt.x, objects[i]->boundingBox.minPt.y, objects[i]->boundingBox.minPt.z);
         printf("%f %f %f\n", objects[i]->boundingBox.maxPt.x, objects[i]->boundingBox.maxPt.y, objects[i]->boundingBox.maxPt.z);
         printf("%f %f %f\n", tempOctTree->boundingBox.minPt.x, tempOctTree->boundingBox.minPt.y, tempOctTree->boundingBox.minPt.z);
         printf("%f %f %f\n", tempOctTree->boundingBox.maxPt.x, tempOctTree->boundingBox.maxPt.y, tempOctTree->boundingBox.maxPt.z);
         
         printf("frack\n");
         
         HANDLE_ERROR(cudaMalloc(&(objArrH[i]), tempSize * sizeof(Triangle)));
         
         printf("whats\n");
         
         HANDLE_ERROR(cudaMemcpy(objArrH[i], tempOctTree, tempSize * sizeof(Triangle), cudaMemcpyHostToDevice));
         
         printf("that\n");
         
         free(tempOctTree);
         
         printf("OH FUCK\n");
         
         //Rebuild tree on device
         gridDimension = int(ceil(sqrt((float(tempSize)) / (float(TILEWIDTH * TILEWIDTH)))));
         printf("GD: %d\n", gridDimension);
         dimGrid = dim3(gridDimension, gridDimension);//dim3((tempSize / TILEWIDTH) + 1, 1);
         dimBlock = dim3(TILEWIDTH,TILEWIDTH);//dim3(TILEWIDTH, 1);
         //printf("kk\n");
         
         
         HANDLE_ERROR(cudaPeekAtLastError());
         HANDLE_ERROR(cudaDeviceSynchronize());
         
         
         toQuadTree<<<dimGrid, dimBlock>>>((Triangle*)(objArrH[i]), tempSize, gridDimension);
         
         HANDLE_ERROR(cudaPeekAtLastError());
         HANDLE_ERROR(cudaDeviceSynchronize());
      } else { //Other object handling (mostly, if not all, planes)
         if (objects[i]->type == 0) {         //SPHERE
            HANDLE_ERROR(cudaMalloc(&(objArrH[i]), sizeof(Sphere)));
            HANDLE_ERROR(cudaMemcpy(objArrH[i], objects[i], sizeof(Sphere), cudaMemcpyHostToDevice));
         } else if (objects[i]->type == 1) {  //PLANE
            HANDLE_ERROR(cudaMalloc(&(objArrH[i]), sizeof(Plane)));
            HANDLE_ERROR(cudaMemcpy(objArrH[i], objects[i], sizeof(Plane), cudaMemcpyHostToDevice));
         } else if (objects[i]->type == 2) {  //TRIANGLE
            HANDLE_ERROR(cudaMalloc(&(objArrH[i]), sizeof(Triangle)));
            HANDLE_ERROR(cudaMemcpy(objArrH[i], objects[i], sizeof(Triangle), cudaMemcpyHostToDevice));
         } else if (objects[i]->type == 3) {  //BOX
            HANDLE_ERROR(cudaMalloc(&(objArrH[i]), sizeof(Box)));
            HANDLE_ERROR(cudaMemcpy(objArrH[i], objects[i], sizeof(Box), cudaMemcpyHostToDevice));
         } else if (objects[i]->type == 4) {  //CONE
            HANDLE_ERROR(cudaMalloc(&(objArrH[i]), sizeof(Cone)));
            HANDLE_ERROR(cudaMemcpy(objArrH[i], objects[i], sizeof(Cone), cudaMemcpyHostToDevice));
         }
         editFuncPtrs<<<1,1>>>(objArrH[i]);
         sizesH[i] = 1;
      }
   }
   
   printf("Photon maps...\n");
   printf("SIZE KD: %lu\n", sizeof(KDTreeNode));
   printf("SIZE PHOTON: %lu\n", sizeof(Photon));
   
   if (globalPhotons) {
      printf("Porting global photons...\n");
      gSize = 0; //yah
      tempInd = 0;
      depth = 1;
      //Get the proper size of the tree
      gSize = globalPhotons->Treesize();
      //Copy over array represenation of tree
      printf("TREE SIZE: %d\n", gSize);
      
      
      tempKDTree = (Photon*)calloc(gSize * 2, sizeof(Photon));
      
      printf("GSIZE: %d\n", gSize);
      printf("ARR SIZE: %lu\n", gSize * sizeof(Photon));
      printf("ARR START POS: %p\n", tempKDTree);
      printf("frick\n");
      printf("P SIZE %lu\n", sizeof(Photon));
      printf("KD SIZE %lu\n", sizeof(KDTreeNode));
      
      globalPhotons->toSerialArray(tempKDTree, &tempInd);
      
      printf("TREE ARR END\n");
      
      printf("frack\n");
      
      HANDLE_ERROR(cudaMalloc(&globalsD, gSize * 2 * sizeof(Photon)));
      
      printf("whats\n");
      
      HANDLE_ERROR(cudaMemcpy(globalsD, tempKDTree, gSize * 2 * sizeof(Photon), cudaMemcpyHostToDevice));
      
      printf("that\n");
      
      free(tempKDTree);
      
      printf("OH FUCK\n");
      
      //Rebuild tree on device
      gridDimension = int(ceil(sqrt((float(gSize)) / (float(TILEWIDTH * TILEWIDTH)))));
      printf("GD: %d\n", gridDimension);
      dimGrid = dim3(gridDimension, gridDimension);//dim3((tempSize / TILEWIDTH) + 1, 1);
      dimBlock = dim3(TILEWIDTH,TILEWIDTH);//dim3(TILEWIDTH, 1);
      
      
      HANDLE_ERROR(cudaPeekAtLastError());
      HANDLE_ERROR(cudaDeviceSynchronize());
      
      
      toKDTree<<<dimGrid, dimBlock>>>(globalsD, gSize, gridDimension);
      
      HANDLE_ERROR(cudaPeekAtLastError());
      HANDLE_ERROR(cudaDeviceSynchronize());
   }
   
   if (causticPhotons) {
      printf("Porting caustic photons...\n");
      cSize = 0;
   }
   
   //Copy device pointers from host array to device array and sizes of each obj pointer struct
   HANDLE_ERROR(cudaMemcpy(objArrD, objArrH, objects.size() * sizeof(SceneObject*), cudaMemcpyHostToDevice));
   HANDLE_ERROR(cudaMemcpy(sizesD, sizesH, objects.size() * sizeof(int), cudaMemcpyHostToDevice));
   
   printf("hiya\n");
   printf("CSIZE: %d\n", cSize);
   
   //Make photon stack
   int treeLength = (gSize > cSize ? gSize : cSize);
   printf("GSIZE: %d\n", gSize);
   printf("CSIZE: %d\n", cSize);
   printf("TREELEN: %d\n", treeLength);
   while (treeLength != 0) {
      depth++;
      treeLength /= 2;
   }
   printf("DEPTH: %d\n", depth);
   
   //HANDLE_ERROR(cudaMalloc(&cudaPhotonStack, depth * 2 * sizeof(KDTreeNode*) * width * height));
   HANDLE_ERROR(cudaMalloc(&cudaPhotonStack, depth * 2 * sizeof(KDTreeNode*) * 640 * 640));
   //printf("ELEMENTS CPR LINDSEY STIRLING: %d\n", depth * 2 * width * height);
   KDTreeNode *node[10];
   int stuff[10];
   printf("Im running out of things to say: %p\n", cudaPhotonStack);
   printf("Im running out of things to say: %p\n", cudaPhotonStack + 1);
   printf("Im running out of things to sayN: %p\n", node);
   printf("Im running out of things to sayN: %p\n", node + 1);
   printf("Im running out of things to sayS: %p\n", stuff);
   printf("Im running out of things to sayS: %p\n", stuff + 1);
   printf("PTR SIZE %d\n", sizeof(KDTreeNode*));
   raytracer = new RayTracer(objArrD, objects.size(), gSize, cSize, reinterpret_cast<KDTreeNode*>(globalsD), reinterpret_cast<KDTreeNode*>(causticsD));
   raytracer->cudaStack = cudaPhotonStack;
   raytracer->stackPartition = depth * 2;
   printf("fam\n");
   
   HANDLE_ERROR(cudaMalloc(&raytracerD, sizeof(RayTracer)));
   HANDLE_ERROR(cudaMemcpy(raytracerD, raytracer, sizeof(RayTracer), cudaMemcpyHostToDevice));
   
   //Make blocks of dimension 32x32, with 32x32 threads on them
   dimGrid = dim3(width / TILEWIDTH, height / TILEWIDTH);
   dimBlock = dim3(TILEWIDTH, TILEWIDTH);
   
   printf("Calling Kernel...\n");
   //Run the Kernel code
   //cudaDeviceSetLimit(cudaLimitMallocHeapSize, size_t(3000000000));
   
   size_t lim, freeM, totalM;
   cudaThreadGetLimit(&lim, cudaLimitStackSize);
   printf("THREAD LIM: %d\n", lim);
   //cudaThreadSetLimit(cudaLimitStackSize, 4096);
   //cudaThreadSetLimit(cudaLimitStackSize, 6184);
   cudaThreadSetLimit(cudaLimitStackSize, 8192);
   
   cudaMemGetInfo(&freeM, &totalM); 
   printf("%lu KB free of total %lu KB\n",((freeM/1024)/2048)/16,((totalM/1024)/2048)/16);

   //cudaThreadSetLimit(cudaLimitStackSize, 16384);
   cudaThreadGetLimit(&lim, cudaLimitStackSize);
   printf("NEW THREAD LIM: %d\n", lim);
   
   //cudaThreadSetLimit(cudaLimitStackSize, 16384);
   cudaThreadGetLimit(&lim, cudaLimitMallocHeapSize);
   printf("THREAD HEAP LIM: %d\n", lim);
   cudaThreadSetLimit(cudaLimitMallocHeapSize, lim*100);
   cudaThreadGetLimit(&lim, cudaLimitMallocHeapSize);
   printf("NEW THREAD HEAP LIM: %d\n", lim);
   printf("TILE WIDTH: %d\n", TILEWIDTH);
   //cudaLimitMallocHeapSize
   //BUG HAPPENS IN HERE
   time(startTime);
   //cudaFuncSetCacheConfig(GIPhotonMapKernel, cudaFuncCachePreferShared);
   //GIPhotonMapKernel<<<dimGrid, dimBlock>>>(objArrD, sizesD, objects.size(), pixelsD, cameraD, width, height, raytracerD); //, globalsD, causticsD);

   GIPhotonMapKernel<<<dimGrid, dimBlock>>>(objArrD, sizesD, objects.size(), pixelsD, cameraD, width, height, raytracerD); //, globalsD, causticsD);
   
   //GIPhotonMapKernel<<<dimGrid, dimBlock>>>(objArrD, objects.size(), pixelsD, cameraD, width, height);
   HANDLE_ERROR(cudaPeekAtLastError());
   HANDLE_ERROR(cudaDeviceSynchronize());
   printf("SIZE GLM VEC: %lu\n", sizeof(glm::vec3));
   printf("SIZE PIXEL: %lu\n", sizeof(Pixel));
   //Copy modified pixel array from card back to host
   printf("Size parray: %d\n", pixelArrSize);
   HANDLE_ERROR(cudaMemcpy(pixels, pixelsD, pixelArrSize, cudaMemcpyDeviceToHost));
   
   //Free the data on the card
   printf("Freeing data on the card...\n");
   //Camera
   HANDLE_ERROR(cudaFree(cameraD));
   //RT
   HANDLE_ERROR(cudaFree(raytracerD));
   
   printf("it\n");
   //Objects
   for (uint i = 0; i < objects.size(); i++) {
   
      HANDLE_ERROR(cudaFree(objArrH[i]));
   }
   printf("is\n");
   HANDLE_ERROR(cudaFree(objArrD));
   HANDLE_ERROR(cudaFree(sizesD));
   //Pixels
   HANDLE_ERROR(cudaFree(pixelsD));
   //free(pixelsD);
   //KDTrees
   printf("where\n");
   if (globalsD) HANDLE_ERROR(cudaFree(globalsD));
   if (causticsD) HANDLE_ERROR(cudaFree(causticsD));
   HANDLE_ERROR(cudaFree(cudaPhotonStack));
   
   //Free other data
   delete raytracer;
   free(sizesH);
   free(objArrH);
}
