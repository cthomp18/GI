#include "tracer.h"

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

__global__ void toOctTree(Triangle *objectArray, int size, int gridDimension) {
   
   OctTreeNode tempO;
   Triangle* tempT;
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
   if (threadInd == 0) {
      printf(":(\n");
   if (threadInd == 0) { printf(":() %d\n", size); }
   if (threadInd == size - 1) { printf("UH SUH DUDE %d\n", size); }
   //__syncthreads();
   if (threadInd < size) {
      /*if (threadInd == size - 1) {
         printf("Thread Index: %d\n", threadInd);
         printf("Block? %d\n", blockIdx.x);
      }*/
      printf("suh\n");
      if (objectArray[threadInd].type == 8) {
         tempO = OctTreeNode((OctTreeNode*)(&(objectArray[threadInd])));
         /*for (i = 0; i < 8; i++) {
            tempO->octants[i] = NULL;
         }*/
         
         //if (threadInd == 0) {
         //printf("B)\n");
         //tempO = (OctTreeNode*)(objectArray + threadInd);
         //printf("xd\n");
         printf("fam\n");
         for (i = 0; i < 8; i++) {
            /*if (threadInd < 16) {
               printf("Index: %d\n", tempO->indeces[i]);
            }*/
            if (tempO.indeces[i] != -1) {
               printf("fuq\n");
               /*if (tempO->octants[i] == NULL) {
                  printf("Cool: %d\n", i);
               }*/
               
               tempO.octants[i] = (SceneObject*)(&(objectArray[tempO.indeces[i]]));
               /*if (tempO->octants[i] == NULL) {
                  printf("Not Cool: %d\n", i);
               }*/
               
            } else {
               tempO.octants[i] = NULL;
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
         printf("diddly\n");
         memcpy(&(objectArray[threadInd]), &tempO, sizeof(OctTreeNode));
         printf("ding\n");
         //delete tempO;
         printf("dong\n");
         //}
      } else {
         //printf("Type: %d\n", objectArray[threadInd].type);
         tempT = new Triangle((Triangle*)(&(objectArray[threadInd])));
         memcpy(&(objectArray[threadInd]), tempT, sizeof(Triangle));
         delete tempT;
      }
      printf("damn\n");
   } else {
      printf("WHAT\n");
      printf("%d\n", threadInd);
      printf("%d\n", size);
      printf("COOL\n");
   }
   //printf("DAWG\n");
   //__syncthreads();
   //printf("%d\n", threadInd);
   //printf("WHAT\n", threadInd);
   if (threadInd == 1) {
      //printf("THE Fasdfadsf\n");
      //printf("OCTANT: %d\n", (&(objectArray[1]))->type);
      //printf("OCTANT: %d\n", ((OctTreeNode*)(&(objectArray[0])))->octants[0]->type);
      tempO = (OctTreeNode*)(&(objectArray[0]));
      
      for (i = 0; i < 8; i++) {
         /*if (tempO->octants[i]) {
            printf("good %d\n", tempO->indeces[i]);
         } else {
            printf("bad %d\n", tempO->indeces[i]);
         }*/
      }
         SceneObject **so;
         //tempO->checkCollision(s, t, 0.0f, so);
   }
   //memcpy(&(objectArray[threadInd]), tempO, sizeof(OctTreeNode));
   //printf("THE FUCK\n");
   //__syncthreads();
   }
   __syncthreads();
   //printf("FUCK\n");
}

__global__ void GIPhotonMapKernel(SceneObject **objArr, int *objSizes, int objSize, Pixel *pixelsD, Camera *camera, int width, int height, RayTracer raytracer) {
   //__shared__ TYPE Mds[TILEWIDTH][TILEWIDTH];
   //__shared__ TYPE Nds[TILEWIDTH][TILEWIDTH];
   int row = blockIdx.y*TILEWIDTH + threadIdx.y;
   int col = blockIdx.x*TILEWIDTH + threadIdx.x;
   if (row == 320 && col == 320) {
   //int c = 0;
   //printf("yo\n");
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
//if (row == 320 && col == 320) {
   printf("hello?\n");
   collision = raytracer.trace(cPos, ray, false);
   printf("whats up?\n");
         //printf("Making sure ;)\n");
   if (collision->time > TOLERANCE) {
      //pixels[i][j].clr = raytrace->calcRadiance(cPos, cPos + ray * col->time, col->object, unit, 1.0f, 1.33f, 0.95f, 5); //Cam must start in air
      tempColor = collision->object->getNormal(cPos + ray * collision->time, 2.0f);
      pixelsD[currentImgInd].clr = (tempColor * 0.5f) + 0.5f;
      //printf("Anything here?\n");
   }
   else {
      pixelsD[currentImgInd].clr = glm::vec3(1.0f, 1.0f, 1.0f);
      //printf("Making sure\n");
   }
   
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
void RayTraceOnDevice(int width, int height, Pixel *pixels, std::vector<SceneObject*> objects, Camera *cam) {
   SceneObject** objArrD;
   SceneObject** objArrH;// = &objects[0];
   int* sizesH;
   int* sizesD;
   int gridDimension;
   
   Triangle* tempOctTree;
   Camera* cameraD;
   Pixel* pixelsD;
   RayTracer* raytracer;
   int tempSize, tempInd, pixelArrSize;
   
   dim3 dimGrid;
   dim3 dimBlock;
   
   pixelArrSize = width * height * sizeof(Pixel);
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
   for (int i = 0; i < objects.size(); i++) {
      //printf("hello\n");
      if (objects[i]->type == 8) { //Oct tree handling
         //printf("yes\n");
         tempInd = 0;
         //Get the proper size of the tree
         tempSize = static_cast<OctTreeNode*>(objects[i])->treeLength();
         sizesH[i] = tempSize;
         
         //Copy over array represenation of tree
         
         tempOctTree = (Triangle*)malloc(tempSize * sizeof(Triangle));
         printf("frick\n");
         static_cast<OctTreeNode*>(objects[i])->toSerialArray(tempOctTree, &tempInd);
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
         toOctTree<<<dimGrid, dimBlock>>>((Triangle*)(objArrH[i]), tempSize, gridDimension);
         //printf("kkk\n");
         HANDLE_ERROR(cudaPeekAtLastError());
         HANDLE_ERROR(cudaDeviceSynchronize());
   
      } else if (objects[i]->type == 5) { //Quad tree handling (Gerstner Wave Triangles)
         sizesH[i] = 1;
      } else { //Other object handling (mostly, if not all, planes)
         sizesH[i] = 1;
      }
   }
   
   //Copy device pointers from host array to device array and sizes of each obj pointer struct
   HANDLE_ERROR(cudaMemcpy(objArrD, objArrH, objects.size() * sizeof(SceneObject*), cudaMemcpyHostToDevice));
   HANDLE_ERROR(cudaMemcpy(sizesD, sizesH, objects.size() * sizeof(int), cudaMemcpyHostToDevice));
   
   printf("hiya\n");
   raytracer = new RayTracer(objArrD, objects.size(), 0, 0, NULL, NULL);
   printf("fam\n");
   
   //Make blocks of dimension 32x32, with 32x32 threads on them
   dimGrid = dim3(width / TILEWIDTH, height / TILEWIDTH);
   dimBlock = dim3(TILEWIDTH, TILEWIDTH);
   
   printf("Calling Kernel...\n");
   //Run the Kernel code
   //cudaDeviceSetLimit(cudaLimitMallocHeapSize, size_t(3000000000));
   //GIPhotonMapKernel<<<dimGrid, dimBlock>>>(objArrD, sizesD, objects.size(), pixelsD, cameraD, width, height, *raytracer);
   //GIPhotonMapKernel<<<dimGrid, dimBlock>>>(objArrD, objects.size(), pixelsD, cameraD, width, height);
   HANDLE_ERROR(cudaPeekAtLastError());
   HANDLE_ERROR(cudaDeviceSynchronize());
   printf("SIZE GLM VEC: %d\n", sizeof(glm::vec3));
   printf("SIZE PIXEL: %d\n", sizeof(Pixel));
   //Copy modified pixel array from card back to host
   printf("Size parray: %d\n", pixelArrSize);
   HANDLE_ERROR(cudaMemcpy(pixels, pixelsD, pixelArrSize, cudaMemcpyDeviceToHost));
   
   //Free the data on the card
   printf("Freeing data on the card...\n");
   //Camera
   HANDLE_ERROR(cudaFree(cameraD));
   printf("it\n");
   //Objects
   for (int i = 0; i < objects.size(); i++) {
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
   
   //Free other data
   delete raytracer;
   free(sizesH);
   free(objArrH);
}
