#include "tracer.h"
// http://stackoverflow.com/questions/3016077/how-to-spot-undefined-behavior
//Chris Lupo's error handling fuction/macro
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

   /*if (threadInd == 0) {
      printf("sup homie\n");
      tempO = new OctTreeNode((OctTreeNode*)(&(objectArray[0])));
      printf("suh\n");
      memcpy(objectArray, tempO, sizeof(OctTreeNode));
      printf(":)\n");
      delete(tempO);
   }*/
   //printf("%d\n", threadInd);
   //printf("xd\n");
   //if (threadInd == 0) {
      //printf("ARR LOC: %p\n", objectArray);}
      //printf(":(\n");
      //printf("SIZE ONODE: %d\n", sizeof(OctTreeNode));
      //printf("SIZE TOTS: %d\n", sizeof(OctTreeNode) * size);
   if (threadInd == 0) { printf(":() %d\n", size); 
      printf("%f %f %f\n", objectArray->boundingBox.minPt.x, objectArray->boundingBox.minPt.y, objectArray->boundingBox.minPt.z);
      printf("%f %f %f\n", objectArray->boundingBox.maxPt.x, objectArray->boundingBox.maxPt.y, objectArray->boundingBox.maxPt.z);
   }
   if (threadInd == size - 1) { printf("UH SUH DUDE %d\n", size); }
   //__syncthreads();
   if (threadInd < size && threadInd >= 0) {
      /*if (threadInd == size - 1) {
         printf("Thread Index: %d\n", threadInd);
         printf("Block? %d\n", blockIdx.x);
      }*/
      //printf("suh\n");
      if (objectArray[threadInd].type == 8) {
         tempO = reinterpret_cast<OctTreeNode*>(objectArray + threadInd);
         /*for (i = 0; i < 8; i++) {
            tempO->octants[i] = NULL;
         }*/
         tempO->checkCollision = &(checkOctTreeCollision);
         tempO->getNormal = &(getOctTreeNormal);
         //if (threadInd == 0) {
         //printf("B)\n");
         //tempO = (OctTreeNode*)(objectArray + threadInd);
         //printf("xd\n");
         //printf("fam\n");
         for (i = 0; i < 8; i++) {
            if (threadInd < 16) {
               //printf("Index: %d\n", tempO->indeces[i]);
            }
            if (tempO->indeces[i] != -1) {
               //printf("fuq\n");
               /*if (tempO->octants[i] == NULL) {
                  printf("Cool: %d\n", i);
               }*/
               
               tempO->octants[i] = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[i]);
               /*if (threadInd == 0) {printf("INDEX: %d\n", tempO->indeces[i]);
               printf("SO CAST: %p\n", reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[i]));
               printf("REG: %p\n", objectArray + tempO->indeces[i]);}*/
               /*if (tempO->octants[i] == NULL) {
                  printf("Not Cool: %d\n", i);
               }*/
               
            } else {
               tempO->octants[i] = NULL;
            }
         }
         if (threadInd == 1) {
            //printf("Index: %d\n", tempO->indeces[i]);
            /*Index: 1
Index: 27182
Index: 54363
Index: 81544
Index: 108725
Index: 135906
Index: 163087
Index: 190268
*/
/*Index: 2
Index: 3399
Index: 6797
Index: 10194
Index: 13592
Index: 16989
Index: 20387
Index: 23784
*/
            //s.y = 1.0;
            //printf("%f %f %f\n", s.x, s.y, s.z);
//printf("%f %f %f\n", t.x, t.y, t.z);
            //tempO->checkCollision(s, t, 0.0f, (SceneObject**)&tempT);
         }
         //printf("diddly\n");
         //memcpy(&(objectArray[threadInd]), tempO, sizeof(OctTreeNode));
         //printf("ding\n");
         //for (i = 0; i < 8; i++) tempO->octants[i] = NULL;
         //delete tempO;
         //printf("dong\n");
         //}
      } else {
         //printf("Type: %d\n", objectArray[threadInd].type);
         /*printf("%d\n", threadInd);
         printf("%d\n", objectArray);
         printf("%d\n", sizeof(Triangle));
         printf("%d\n", sizeof(OctTreeNode));
         printf("%d\n", &(objectArray[threadInd]));*/
         //tempT = reinterpret_cast<Triangle*>(objectArray + threadInd);
         tempT = objectArray + threadInd;
         tempT->checkCollision = &(checkTriCollision);
         tempT->getNormal = &(getTriNormal);
         //memcpy(&(objectArray[threadInd]), tempO, sizeof(OctTreeNode));
         //memcpy(&(objectArray[threadInd]), tempT, sizeof(Triangle));
         //delete tempT;
      }
      //printf("damn\n");
   } else {
      //printf("WHAT\n");
      //printf("%d\n", threadInd);
      //printf("%d\n", size);
      //printf("COOL\n");
   }
   //printf("DAWG\n");
   //__syncthreads();
   //printf("%d\n", threadInd);
   //printf("WHAT\n", threadInd);
   if (threadInd == 1) {
      //printf("THE Fasdfadsf\n");
      //printf("OCTANT: %d\n", (&(objectArray[1]))->type);
      //printf("OCTANT: %d\n", ((OctTreeNode*)(&(objectArray[0])))->octants[0]->type);
      //tempO = (OctTreeNode*)(&(objectArray[0]));
      
      for (i = 0; i < 8; i++) {
         /*if (tempO->octants[i]) {
            printf("good %d\n", tempO->indeces[i]);
         } else {
            printf("bad %d\n", tempO->indeces[i]);
         }*/
      }
         //SceneObject **so;
         //tempO->checkCollision(s, t, 0.0f, so);
   }
   //}
   //memcpy(&(objectArray[threadInd]), tempO, sizeof(OctTreeNode));
   //printf("THE FUCK\n");
   //__syncthreads();
   __syncthreads();
   //printf("FUCK\n");
}

__global__ void toQuadTree(Triangle *objectArray, int size, int gridDimension) {
   Triangle* tempT;
   QuadTreeNode* tempO;
   
   int threadInd = (blockIdx.y * (gridDimension * TILEWIDTH) * TILEWIDTH) + (blockIdx.x * TILEWIDTH) +
                   (threadIdx.y * (gridDimension * TILEWIDTH)) + threadIdx.x;//blockIdx.x;//*TILEWIDTH + threadIdx.x;
   int i;

   /*if (threadInd == 0) { printf(":() %d\n", size); 
      printf("%f %f %f\n", objectArray->boundingBox.minPt.x, objectArray->boundingBox.minPt.y, objectArray->boundingBox.minPt.z);
      printf("%f %f %f\n", objectArray->boundingBox.maxPt.x, objectArray->boundingBox.maxPt.y, objectArray->boundingBox.maxPt.z);
   }*/
   //if (threadInd == size - 1) { printf("UH SUH DUDE %d\n", size); }
   
   if (threadInd < size && threadInd >= 0) {
      if (objectArray[threadInd].type == 7) {
         tempO = reinterpret_cast<QuadTreeNode*>(objectArray + threadInd);
         
         tempO->checkCollision = &(checkQuadTreeCollision);
         tempO->getNormal = &(getQuadTreeNormal);

         if (tempO->indeces[0] != -1) {
            tempO->q1 = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[0]);
         } else {
            tempO->q1 = NULL;
         }
         if (tempO->indeces[1] != -1) {
            tempO->q2 = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[1]);
         } else {
            tempO->q2 = NULL;
         }
         if (tempO->indeces[2] != -1) {
            tempO->q3 = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[2]);
         } else {
            tempO->q3 = NULL;
         }
         if (tempO->indeces[3] != -1) {
            tempO->q4 = reinterpret_cast<SceneObject*>(objectArray + tempO->indeces[3]);
         } else {
            tempO->q4 = NULL;
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

   if (threadInd == 0) { printf(":() %d\n", size); 
      //printf("%f %f %f\n", objectArray->boundingBox.minPt.x, objectArray->boundingBox.minPt.y, objectArray->boundingBox.minPt.z);
      //printf("%f %f %f\n", objectArray->boundingBox.maxPt.x, objectArray->boundingBox.maxPt.y, objectArray->boundingBox.maxPt.z);
   }
   if (threadInd == size - 1) { printf("UH SUH DUDE %d\n", size); }
   
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
   } else {
      /*printf("WHAT\n");
      printf("%d\n", threadInd);
      printf("%d\n", size);*/
   }

   __syncthreads();
}

__global__ void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objSize, Pixel *pixelsD, Camera *camera, int width, int height, RayTracer *raytracer) {//, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons) {
   //__shared__ TYPE Mds[TILEWIDTH][TILEWIDTH];
   //__shared__ TYPE Nds[TILEWIDTH][TILEWIDTH];
   int row = blockIdx.y*TILEWIDTH + threadIdx.y;
   int col = blockIdx.x*TILEWIDTH + threadIdx.x;
   //if (row == 0 && col == 0) printf("cool\n");
   //if (row == 639 && col == 639) printf("cooler\n");
   //if (row > 616) {// && col < 240) {
   //int c = 0;
   //printf("yo\n");
   /*printf("REG MIN %f %f %f\n", objArr[0]->boundingBox.minPt.x, objArr[0]->boundingBox.minPt.y, objArr[0]->boundingBox.minPt.z);
   printf("REG MAX %f %f %f\n", objArr[0]->boundingBox.maxPt.x, objArr[0]->boundingBox.maxPt.y, objArr[0]->boundingBox.maxPt.z);
   printf("RAY MIN %f %f %f\n", raytracer->objects[0]->boundingBox.minPt.x, raytracer->objects[0]->boundingBox.minPt.y, raytracer->objects[0]->boundingBox.minPt.z);
   printf("RAY MAX %f %f %f\n", raytracer->objects[0]->boundingBox.maxPt.x, raytracer->objects[0]->boundingBox.maxPt.y, raytracer->objects[0]->boundingBox.maxPt.z);*/
   glm::vec3 cPos = camera->getPosition();
   //glm::vec3 cPos = glm::vec3(0.0, 0.0, 0.0);
   //RayTracer* raytrace = new RayTracer(objArr, 0, 0, 0, 0, 0);
   //delete(raytrace);
   int currentImgInd;
   
   //Collision* col = new Collision();
   //delete(col);
   //for (int i = 0; i < width / TILEWIDTH; i++) {
   //i * imgheight + j;
      //int threadIndex = row*width1 + (m*TILEWIDTH + threadIdx.x);
      //Nds[threadIdx.y][threadIdx.x] = Nd[col + (m*TILEWIDTH + threadIdx.y)*width2];
      //cout << "i: " << i << endl;
   Collision* collision;
   glm::vec3 ray, tempColor;
      //for (int j = 0; j < height; j++) {
   currentImgInd = col * height + row;
   ray = pixelsD[currentImgInd].pt;// - cPos;
   ray = glm::normalize(ray);

   /*if (currentImgInd == 0) {
      //printf("First Obj Type: %d\n", objArr[0]->type);
      OctTreeNode* o = (OctTreeNode*)objArr[0];
      
      printf("Huh %d\n", o->type);
      printf("ImgInd: %d\n", currentImgInd);
      
      for(int i = 0; i < 8; i++) {
         if (o->octants[i] != NULL) {
            printf("Oct Type: %d\n", o->octants[i]->type);
         } else {
            printf("Null Oct: %d\n", i);
         }
      }
      printf("Tree size: %d\n", o->treeLength());
   }*/
if (col < 100) {// && row == 0) {
   //printf("Im running out of things to say: %p\n", raytracer->cudaStack);
   //printf("Im running out of things to say: %p\n", raytracer->cudaStack + 1);
   //printf("ROW %d\n", row);
//if (currentImgInd < 0) {
   //printf("hello?\n");
    
   collision = raytracer->trace(cPos, ray, false);
    
   //printf("whats up?\n");
         //printf("Making sure ;)\n");
         //printf("HI\n");
   if (collision) {
      //printf("UH SUH\n");
   } else {
      printf(" WUT \n");
   }
   if (collision->time > TOLERANCE) {
      //printf("in here?\n");
      pixelsD[currentImgInd].clr = raytracer->calcRadiance(cPos, cPos + ray * collision->time, collision->object, false, 1.0f, 1.33f, 0.95f, currentImgInd, 0);//(threadIdx.y * TILEWIDTH) + threadIdx.x, 0); //Cam must start in air
      if (collision->object) {
         //printf("yo wasuu\n");
         //printf("%d\n", collision->object->type);
      } else {
         //printf("k\n");
      }
      //tempColor = collision->object->getNormal(collision->object, cPos + ray * collision->time, 2.0f);
      //printf(" WUT \n");
      //pixelsD[currentImgInd].clr = (tempColor * 0.5f) + 0.5f;
      //printf("Anything here?\n");
      //pixelsD[currentImgInd].clr = glm::vec3(1.0f, 1.0f, 1.0f);
   }
   else {
      //printf("should not be in here\n");
      pixelsD[currentImgInd].clr = glm::vec3(1.0f, 1.0f, 1.0f);
      //printf("Making sure\n");
   }
   //printf("WHAT\n");
   //printf("ROW END %d\n", row);
   delete(collision);
}
   //}
         //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
      //}
   //}
   __syncthreads();
   
   
   /*for (int i = 0; i < width * height; i++) {
      pixelsD[i].clr.x = pixelsD[i].clr.y = pixelsD[i].clr.z = 1.0;
   }*/
}

// Set the card up to run cuda
void RayTraceOnDevice(int width, int height, Pixel *pixels, std::vector<SceneObject*> objects, Camera *cam, KDTreeNode *globalPhotons, KDTreeNode *causticPhotons) {
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
      
      //if (threadNum == 0) {
         //printf("TREE START\n");
         //globalPhotons->printTree(globalPhotons);
         //printf("TREE END\n");
     // }   
      globalPhotons->toSerialArray(tempKDTree, &tempInd);
      
      /*printf("TREE ARR START\n");
      for (int i = 0; i < gSize * 2; i++) {
         if (i % 2 == 0) {
            printf("AXIS: %d\n", reinterpret_cast<KDTreeNode*>(tempKDTree + i)->axis);
            printf("LEFT IND: %d, RIGHT IND: %d\n", reinterpret_cast<KDTreeNode*>(tempKDTree + i)->leftInd, reinterpret_cast<KDTreeNode*>(tempKDTree + i)->rightInd);
         } else {
            printf("Pt: %f %f %f\n", tempKDTree[i].pt.x, tempKDTree[i].pt.y, tempKDTree[i].pt.z);
         }
      }*/
      //globalPhotons->printTree(globalPhotons);
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
      //printf("kk\n");
      
      
      HANDLE_ERROR(cudaPeekAtLastError());
      HANDLE_ERROR(cudaDeviceSynchronize());
      
      
      toKDTree<<<dimGrid, dimBlock>>>(globalsD, gSize, gridDimension);
      
      //printf("TREE START\n");
      //globalPhotons->printTree(globalPhotons);
      //printf("TREE END\n");
         
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
   
   HANDLE_ERROR(cudaMalloc(&cudaPhotonStack, depth * 2 * sizeof(KDTreeNode*) * 640 * 640));
   
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
   
   size_t lim;
   cudaThreadGetLimit(&lim, cudaLimitStackSize);
   printf("THREAD LIM: %d\n", lim);
   //cudaThreadSetLimit(cudaLimitStackSize, 4096);
   cudaThreadSetLimit(cudaLimitStackSize, 8192);
   //cudaThreadSetLimit(cudaLimitStackSize, 16384);
   cudaThreadGetLimit(&lim, cudaLimitStackSize);
   printf("NEW THREAD LIM: %d\n", lim);
   
   //BUG HAPPENS IN HERE
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
