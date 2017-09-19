/*
   Cody Thompson
   Photon Mapping
*/

#include <iostream>
//#include "RayTracer.h"
#include "RayTracer.cuh"

using namespace std;

//extern __shared__ float sh[];

RayTracer::RayTracer(std::vector<Light*>* l, std::vector<SceneObject*>* o) {
   lights = &((*l)[0]);
   objects = &((*o)[0]);
   objSize = (*o).size();
   
   /*printf("OBJ SIZE: %d\n", (*o).size());
   printf("ADSFASDF %d\n", objSize);
   printf("TYPE   %d\n", objects[0]->type);
   for (int i = 0; i < (*o).size(); i++) {
      if (!(*o)[i]) printf("FUCKKaadsfasdf %d\n", i);
   }*/
   
   cudaStack = NULL;
}

RayTracer::RayTracer(std::vector<Light*>* l, std::vector<SceneObject*>* o, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr) {
   lights = &((*l)[0]);
   objects = &((*o)[0]);
   objSize = (*o).size();
   numGPhotons = gM;
   numCPhotons = cM;
   root = gr;
   rootC1 = cr;
   /*printf("OBJ SIZE: %d\n", (*o).size());
   printf("ADSFASDF %d\n", objSize);
   printf("TYPE   %d\n", objects[0]->type);
   for (int i = 0; i < (*o).size(); i++) {
      if (!objects[i]) printf("FUCKKaadsfasdf %d\n", i);
   }*/
   
   cudaStack = NULL;
}

RayTracer::RayTracer(SceneObject** o, int osize, int gM, int cM, KDTreeNode* gr, KDTreeNode* cr) {
   objects = o;
   objSize = osize;
   numGPhotons = gM;
   numCPhotons = cM;
   root = gr;
   rootC1 = cr;
   
   cudaStack = NULL;
}

RayTracer::RayTracer() {
   cudaStack = NULL;
}
RayTracer::~RayTracer() { }

//Collision* RayTracer::trace(glm::vec3 start, glm::vec3 ray, bool unit) {
Collision* RayTracer::trace(glm::vec3 start, glm::vec3 ray, bool unit, int *shI, float *shF) {
   Collision* c = new Collision();

   shF[6] = start.x;
   shF[7] = start.y;
   shF[8] = start.z;

   c->detectRayCollision2(ray, objects, objSize, -1, unit, shI, shF);
   return c;
}

Collision* RayTracer::trace(glm::vec3 ray, int *shI, float *shF) {
//Collision* RayTracer::trace(glm::vec3 start, glm::vec3 ray, int *shI, float *shF) {

   //I01: Omit Index

   Collision* c = new Collision();
   
   shI[2] = objSize;
   
   c->detectRayCollision(ray, objects, shI, shF);
   return c;
}

__device__ __noinline__ volatile float * volatile RayTracer::getMatInv(glm::vec3 iPt, SceneObject* obj, float *shF) {
   /*
   7: c
   8: s
   9: t
   */
   
   glm::mat3 matInv;
   glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   glm::vec3 eRay = glm::vec3(0.0, 0.0, 1.0);
   
   normal = glm::normalize(normal);
   if (fabs(ELLIPSOID_SCALE - 1.0) > TOLERANCE &&
       (fabs(fabs(normal[0]) - eRay[0]) > TOLERANCE ||
        fabs(fabs(normal[1]) - eRay[1]) > TOLERANCE ||
        fabs(fabs(normal[2]) - eRay[2]) > TOLERANCE)) {
        
      glm::vec3 crossP = glm::cross(eRay, normal);
      crossP = glm::normalize(crossP);
      
      shF[6] = glm::dot(eRay, normal); shF[7] = sin(acos(glm::dot(eRay, normal))); shF[8] = 1.0 - shF[6];
      glm::mat3 mat = glm::mat3(shF[8]*crossP.x*crossP.x + shF[6], shF[8]*crossP.x*crossP.y - crossP.z*shF[7], shF[8]*crossP.x*crossP.z + crossP.y*shF[7],
                                shF[8]*crossP.x*crossP.y + crossP.z*shF[7], shF[8]*crossP.y*crossP.y + shF[6], shF[8]*crossP.y*crossP.z - crossP.x*shF[7],
                                shF[8]*crossP.x*crossP.z - crossP.y*shF[7], shF[8]*crossP.y*crossP.z + crossP.x*shF[7], shF[8]*crossP.z*crossP.z + shF[6]);
      matInv = glm::inverse(mat);
   } else {
      matInv = glm::mat3(1.0f);
   }
   
   //volatile float* volatile mInv;// = 
   return glm::value_ptr(matInv);
}

__device__ __noinline__ glm::vec3 RayTracer::accumulatePhotons(Photon **locateHeap, glm::vec3 iPt, SceneObject* obj, float *shF, int *shI) {
   glm::vec3 clr(0.0f, 0.0f, 0.0f);
   for (volatile int i = 0; i < shI[2]; i++) {
      //BRDF
      glm::vec3 normal = obj->getNormal(obj, iPt, shF);
      normal = glm::normalize(normal);
      float dotProd = glm::dot(-locateHeap[i]->incidence, normal);
      //if (shI[0] < causts) {
         //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      //} else {
         //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
         //clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
      //}
   }
   return clr;
}

__attribute__ ((noinline)) void __attribute__ ((noinline)) RayTracer::getNormal(SceneObject *obj, glm::vec3 iPt, float *shF) {
   glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   normal = glm::normalize(normal);
   shF[3] = normal.x;
   shF[4] = normal.y;
   shF[5] = normal.z;
}

glm::vec3 RayTracer::calcRadiance(glm::vec3 start, glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int threadNum, int depth, int *shI, float *shF) {
   /*float e = 2.71828;
   float alpha = 0.918;
   float beta = 1.953;*/
      
   //int causts;
   //volatile float x = 0.0f, y = 0.0f, z = 0.0f, t = 0.0f, c = 0.0f, s = 0.0f;
   //printf("THREADNUM: %d\n", threadNum);
   //float sampleDistSqrd, newRadSqrd;//, scaleN;
   //Photon** locateHeap;// = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));;
   //int heapSize;
   //glm::vec3 eRay = glm::vec3(0.0, 0.0, 1.0);
   //glm::mat3 mat, matInv;
   //volatile float reflectScale = obj->reflection;
   //volatile float * volatile matInv;
      //if (1) matInv = (volatile float * volatile)glm::value_ptr(glm::mat3(1.0f));//getMatInv(iPt, obj, shF);
      //if (1) matInv = getMatInv(iPt, obj, shF);
   //glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   getNormal(obj, iPt, shF);
      //normal = glm::normalize(normal);
   shF[1] = obj->reflection;
   //volatile float refract = obj->refraction;
   shF[2] = obj->refraction;
   //float dropoffCalc = glm::length(iPt - start);
   shF[0] = glm::length(iPt - start);
   //dropoffCalc = pow(dropoff, dropoffCalc);
   shF[0] = pow(dropoff, shF[0]);
   
   //glm::vec3 clr, absorbClr, reflectClr, refractClr;
   glm::vec3 clr(0.0f, 0.0f, 0.0f);
   //float n2 = 0.0f;//, reflectScale = 0.0f, tempDO = 0.0f;//, dots1 = 0.0, dots2 = 0.0, temp, temp2, mainDist, mainT, dist, reflectance = 1.0f / obj->roughness, D, F, G, m, sroot, R = 0.0f, R0 = 0.0f, innersqr = 1.0f;
   //glm::vec3 colorD, colorS, colorA, color, normal, reflectRay, newStart, newIPt, crossP;
   //glm::vec4 tempNormal, tempStart, tempIPt;
   //glm::vec3 pigment(obj->pigment.x, obj->pigment.y, obj->pigment.z);
   //glm::vec3 l, v, h, lcol, dir;
   
   //color = glm::vec3(0.0f, 0.0f, 0.0f);
   
   //glm::vec3 normal = obj->getNormal(obj, iPt, shF);
   //normal = glm::normalize(normal);
   
   //v = start - iPt;
   //v = glm::normalize(v);
   //dir = -v;

   //Collision* col;
   
   //float time = glm::length(iPt - start);
   //float dropoffCalc = pow(dropoff, time);
   
   //absorbClr.x = reflectClr.x = refractClr.x = 0.0;
   //absorbClr.y = reflectClr.y = refractClr.y = 0.0;
   //absorbClr.z = reflectClr.z = refractClr.z = 0.0;
   
   //colorD = pigment * obj->diffuse;
   //colorS = pigment * obj->specular;
   //colorA = pigment * obj->ambient;
   
   //if (fabs(1.0f - refract) > TOLERANCE || depth <= 0) {
      //reflectScale = obj->reflection;
      
      
      
      //printf("%d\n", threadNum);
      //Photon** locateHeap = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));
      
      Photon** locateHeap = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));
      //int heapSize = 0;
      //heapSize = 0;
      //if (numCPhotons > 0) rootC1->locatePhotons(1, iPt, locateHeap, &heapSize, 0.05, &newRadSqrd, matInv, numCPhotons, cudaStack + (threadNum * stackPartition)); 
      //causts = heapSize;
      //volatile int causts = 0;//shI[2];
      
      //sh[threadSpot] = iPt.x;
      //sh[threadSpot+1] = iPt.y;
      //sh[threadSpot+2] = iPt.z;
      shF[7] = INITIAL_SAMPLE_DIST_SQRD;
      shF[8] = INITIAL_SAMPLE_DIST_SQRD;
      shI[2] = 0;//heapSize;
      //asm volatile("membar.cta;");
      volatile float * volatile matInv;
      if (1) matInv = (volatile float * volatile)glm::value_ptr(glm::mat3(1.0f));//getMatInv(iPt, obj, shF);
      //matInv = getMatInv(iPt, obj, shF);
      //if (numGPhotons > 0) root->locatePhotons(iPt, locateHeap, matInv, numGPhotons, shF + threadSpotF, shI + threadSpotI);// cudaStack + (threadNum * stackPartition));
      shI[0] = numGPhotons;
      //asm volatile("membar.cta;");
      if (numGPhotons) root->locatePhotons(iPt, locateHeap, matInv, numGPhotons, shF, shI);// cudaStack + (threadNum * stackPartition));
      //printf("HEAPSIZE FAM: %d\n", heapSize);
      //sh[threadSpot] = 0.1f;
      //if (numGPhotons > 0) root->locatePhotons(iPt, threadSpot, locateHeap, sampleDistSqrd, &newRadSqrd, numGPhotons, sh);
      //printf("sheeeet\n");
      //heapSize = shI[2];
      //printf("HS: %d\n", heapSize);
      //if (heapSize) {
      //   printf("PTN INT: %f %f %f\n", locateHeap[0]->intensity.x, locateHeap[0]->intensity.y, locateHeap[0]->intensity.z);
      //}
      //for (int i = 0; i < heapSize; i++) {
      //clr = accumulatePhotons(locateHeap, iPt, obj, shF, shI);
      /*for (volatile int i = 0; i < shI[2]; i++) {
         //BRDF
         glm::vec3 normal = obj->getNormal(obj, iPt, shF);
         normal = glm::normalize(normal);
         float dotProd = glm::dot(-locateHeap[i]->incidence, normal);
         //if (shI[0] < causts) {
            //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
            clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
         //} else {
            //color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
            //clr += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
         //}
      }*/
      //color /= shF[8] * M_PI;
      //clr /= shF[8] * M_PI;
      
      //color *= (1.0 - obj->reflection) * scale;
      //clr *= (1.0 - reflectScale) * scale;
      //clr.x = clr.x * (1.0f - reflectScale) * scale;
      //absorbClr.x = color.x;
      //absorbClr.y = color.y;
      //absorbClr.z = color.z;
      //clr.x += color.x * dropoffCalc;
      //clr.y += color.y * dropoffCalc;
      //clr.z += color.z * dropoffCalc;
      //clr += color;
      
      free(locateHeap);
      
   //} 
   /*else {
      if (depth > 0) {         
         //Do Refraction
         reflectRay = findRefract(dir, normal, obj, n1, &n2, &reflectScale, &tempDO);
         if (fabs(reflectScale - 1.0f) >= TOLERANCE) { //Total internal reflection carry-over check
            shF[6] = iPt.x;
            shF[7] = iPt.y;
            shF[8] = iPt.z;
            col = trace(reflectRay, shI, shF);
            //col = trace(iPt, reflectRay, shI, shF);
            if (col->time >TOLERANCE) {
               //refractClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * (1.0f - reflectScale), n2, tempDO, threadNum, depth - 1, shI, shF);
               color = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * (1.0f - reflectScale), n2, tempDO, threadNum, depth - 1, shI, shF);
               clr.x += color.x * dropoffCalc;
               clr.y += color.y * dropoffCalc;
               clr.z += color.z * dropoffCalc;
            }
            delete(col);
         }
      }
   }*/

   /*if ((obj->reflection > TOLERANCE || fabs(obj->refraction - 1.0) < TOLERANCE) && depth > 0) {
      //float randFloat;
      reflectRay = findReflect(dir, normal, obj);
      shF[6] = iPt.x;
      shF[7] = iPt.y;
      shF[8] = iPt.z;
      col = trace(reflectRay, shI, shF);
      //col = trace(iPt, reflectRay, shI, shF);
      if (col->time >= TOLERANCE) {
         //reflectClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * reflectScale, n1, dropoff, threadNum, depth - 1, shI, shF);
         color = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * reflectScale, n1, dropoff, threadNum, depth - 1, shI, shF);
         clr.x += color.x * dropoffCalc;
         clr.y += color.y * dropoffCalc;
         clr.z += color.z * dropoffCalc;
      }
      delete(col);
   }*/

   //time = glm::length(iPt - start);
   //float dropoffCalc = pow(dropoff, time);
   //clr.x += (absorbClr.x + reflectClr.x + refractClr.x) * dropoffCalc;
   //clr.y += (absorbClr.y + reflectClr.y + refractClr.y) * dropoffCalc;
   //clr.z += (absorbClr.z + reflectClr.z + refractClr.z) * dropoffCalc;
   
   
   clr *= shF[0];
   
	return clr;
}

/*glm::vec3 RayTracer::calcRadiance(glm::vec3 start, glm::vec3 iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int threadNum, int depth, int *shI, float *shF) {
   //float e = 2.71828;
   //float alpha = 0.918;
   //float beta = 1.953;
      
   int causts;
   float x = 0.0f, y = 0.0f, z = 0.0f, t = 0.0f, c = 0.0f, s = 0.0f;
   //printf("THREADNUM: %d\n", threadNum);
   //float sampleDistSqrd, newRadSqrd;//, scaleN;
   Photon** locateHeap;// = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));;
   int heapSize;
   glm::vec3 eRay = glm::vec3(0.0, 0.0, 1.0);
   glm::mat3 mat, matInv;
   
   glm::vec3 clr, absorbClr, reflectClr, refractClr;
   float n2 = 0.0f, time = 0.0f, reflectScale = 0.0f, tempDO = 0.0f;//, dots1 = 0.0, dots2 = 0.0, temp, temp2, mainDist, mainT, dist, reflectance = 1.0f / obj->roughness, D, F, G, m, sroot, R = 0.0f, R0 = 0.0f, innersqr = 1.0f;
   glm::vec3 colorD, colorS, colorA, color, normal, reflectRay, newStart, newIPt, crossP;
   glm::vec4 tempNormal, tempStart, tempIPt;
   glm::vec3 pigment(obj->pigment.x, obj->pigment.y, obj->pigment.z);
   glm::vec3 l, v, h, lcol, dir;
   
   color = glm::vec3(0.0f, 0.0f, 0.0f);
   clr.x = clr.y = clr.z = 0.0;
   //locateHeap.clear();
   //sampleDistSqrd = newRadSqrd = INITIAL_SAMPLE_DIST_SQRD;
   
   normal = obj->getNormal(obj, iPt, shF);
   normal = glm::normalize(normal);
   
   v = start - iPt;
   v = glm::normalize(v);
   dir = -v;

   Collision* col;
   //bool shadow;
   
   absorbClr.x = reflectClr.x = refractClr.x = 0.0;
   absorbClr.y = reflectClr.y = refractClr.y = 0.0;
   absorbClr.z = reflectClr.z = refractClr.z = 0.0;
   
   colorD = pigment * obj->diffuse;
   colorS = pigment * obj->specular;
   colorA = pigment * obj->ambient;
   
   //if (threadNum == 0) {
   //   printf("STACK PART: %d\n", stackPartition);
   //}
   //if (threadNum == 0) {
   //   printf("TREE START\n");
   //   root->printTree(root);
   //   printf("TREE END\n");
   //}  
   //if (threadNum == 0) {
   if (fabs(1.0f - obj->refraction) > TOLERANCE || depth <= 0) {
      
      /*for (int lightnum = 0; lightnum < lights.size(); lightnum++) {
         dots1 = dots2 = 0.0f;
         shadow = false;
         lcol = lights[lightnum]->getColor();
         lcol = Eigen::Vector3f(1.0f, 1.0f, 1.0f);
         l = (lights[lightnum]->getPosition() - iPt);
         mainDist = l.norm();
         l.normalize();
         h = (l + v);
         h.normalize();
         l.normalize();
         col = new Collision();
         col->detectRayCollision(iPt, l, objects, -1, unit);
         if (col->time >= TOLERANCE && (l*col->time).norm() < mainDist) shadow = true;
         delete(col);
         if (shadow == false) {
            dots1 = l.dot(normal);
            if (dots1 < TOLERANCE) { 
               dots1 = 0.0f;
            }
            
            temp = dots2 = h.dot(normal);
            if (dots2 < TOLERANCE) { 
               dots2 = 0.0f;
            } else {
               for (int i = 0; i < int(reflectance); i++) {
            	   dots2 *= temp;
            	}
            }
         }
         color.x() += ((colorA.x() / float(lights.size())) + (colorD.x() * dots1) + (colorS.x() * dots2)) * lcol.x();
         color.y() += ((colorA.y() / float(lights.size())) + (colorD.y() * dots1) + (colorS.y() * dots2)) * lcol.y();
         color.z() += ((colorA.z() / float(lights.size())) + (colorD.z() * dots1) + (colorS.z() * dots2)) * lcol.z();
      }*//*
      reflectScale = obj->reflection;
      
      //glm::mat3 matInv;
      if (fabs(ELLIPSOID_SCALE - 1.0) > TOLERANCE &&
          (fabs(fabs(normal[0]) - eRay[0]) > TOLERANCE ||
           fabs(fabs(normal[1]) - eRay[1]) > TOLERANCE ||
           fabs(fabs(normal[2]) - eRay[2]) > TOLERANCE)) {
         crossP = glm::cross(eRay, normal);
         crossP = glm::normalize(crossP);
         
         //float x = 0.0f, y = 0.0f, z = 0.0f, t = 0.0f, c = 0.0f, s = 0.0f;
         x = crossP.x; y = crossP.y; z = crossP.z;
         c = glm::dot(eRay, normal); s = sin(acos(glm::dot(eRay, normal))); t = 1.0 - c;
         mat = glm::mat3(t*x*x + c, t*x*y - z*s, t*x*z + y*s,
                                   t*x*y + z*s, t*y*y + c, t*y*z - x*s,
                                   t*x*z - y*s, t*y*z + x*s,	t*z*z + c);
         matInv = glm::inverse(mat);
      } else {
         matInv = glm::mat3(1.0f);
      }
      
      //inv stuff
      //volatile glm::mat3 volatile mInv;
      //mInv.value[0].x = matInv[0][0];
      //mInv.value[0].y = matInv[0][1];
      //mInv.value[0].z = matInv[0][2];
      //mInv.value[1].x = matInv[1][0];
      //mInv.value[1].y = matInv[1][1];
      //mInv.value[1].z = matInv[1][2];
      //mInv.value[2].x = matInv[2][0];
      //mInv.value[2].y = matInv[2][1];
      //mInv.value[2].z = matInv[2][2];
      
      volatile float* volatile mInv = glm::value_ptr(matInv);
      
      //printf("%d\n", threadNum);
      //Photon** locateHeap = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));
      
      locateHeap = (Photon**)malloc(CUTOFF_HEAP_SIZE * sizeof(Photon*));
      //int heapSize = 0;
      heapSize = 0;
      //if (numCPhotons > 0) rootC1->locatePhotons(1, iPt, locateHeap, &heapSize, 0.05, &newRadSqrd, matInv, numCPhotons, cudaStack + (threadNum * stackPartition));
      causts = heapSize;
      
      //printf("I'm guesssing here\n");
      
      //sh[threadSpot] = iPt.x;
      //sh[threadSpot+1] = iPt.y;
      //sh[threadSpot+2] = iPt.z;
      shF[7] = INITIAL_SAMPLE_DIST_SQRD;
      shF[8] = INITIAL_SAMPLE_DIST_SQRD;
      shI[2] = 0;//heapSize;
      //if (numGPhotons > 0) root->locatePhotons(iPt, locateHeap, matInv, numGPhotons, shF + threadSpotF, shI + threadSpotI);// cudaStack + (threadNum * stackPartition));
      if (numGPhotons > 0) root->locatePhotons(iPt, locateHeap, mInv, numGPhotons, shF, shI);// cudaStack + (threadNum * stackPartition));
      //sh[threadSpot] = 0.1f;
      //if (numGPhotons > 0) root->locatePhotons(iPt, threadSpot, locateHeap, sampleDistSqrd, &newRadSqrd, numGPhotons, sh);
      heapSize = shI[2];
      //printf("HS: %d\n", heapSize);
      //if (heapSize) {
      //   printf("PTN INT: %f %f %f\n", locateHeap[0]->intensity.x, locateHeap[0]->intensity.y, locateHeap[0]->intensity.z);
      //}
      //for (int i = 0; i < heapSize; i++) {
      for (int i = 0; i < heapSize; i++) {
         //BRDF
         float dotProd = glm::dot(-locateHeap[i]->incidence, normal);
         //volatile float dotProd = -(locateHeap[i]->incidence.x) * normal.x;//glm::dot(-locateHeap[i]->incidence, normal);
         //dotProd += -(locateHeap[i]->incidence.y) * normal.y;
         //dotProd += -(locateHeap[i]->incidence.z) * normal.z;
         if (i < causts) {
            //float d = glm::length(locateHeap[i]->pt - iPt);
            //float w = alpha * (1 - ((1 - pow(e, -1 * beta * ((d * d) / (2 * newRadSqrd)))) / (1 - pow(e, -1 * beta))));
            color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);// * w;//* (1.0 - ((locateHeap[i]->pt - intersectPt).norm() / sqrt(newRadSqrd)));
         } else {
            //dotProd = (dotProd > 0.0f ? dotProd : 0.0f);
            //color.x += locateHeap[i]->intensity.x * dotProd;
            //color.y += locateHeap[i]->intensity.x * dotProd;
            //color.z += locateHeap[i]->intensity.x * dotProd;
            //if (dotProd < TOLERANCE) dotProd = 0.0f;
            //color += locateHeap[i]->intensity * dotProd;
            color += (locateHeap[i]->intensity) * (dotProd > 0.0f ? dotProd : 0.0f);
         }
      }
      color /= shF[8] * M_PI;
      
      color *= (1.0 - obj->reflection) * scale;
      absorbClr.x = color.x;
      absorbClr.y = color.y;
      absorbClr.z = color.z;
      
      
      free(locateHeap);
      
   } else {
      if (depth > 0) {         
         //Do Refraction
         reflectRay = findRefract(dir, normal, obj, n1, &n2, &reflectScale, &tempDO);
         if (fabs(reflectScale - 1.0f) >= TOLERANCE) { //Total internal reflection carry-over check
            shF[6] = iPt.x;
            shF[7] = iPt.y;
            shF[8] = iPt.z;
            col = trace(reflectRay, shI, shF);
            //col = trace(iPt, reflectRay, shI, shF);
            if (col->time >TOLERANCE) {
               refractClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * (1.0f - reflectScale), n2, tempDO, threadNum, depth - 1, shI, shF);
            }
            delete(col);
         }
      }
   }

   if ((obj->reflection > TOLERANCE || fabs(obj->refraction - 1.0) < TOLERANCE) && depth > 0) {
      //float randFloat;
      reflectRay = findReflect(dir, normal, obj);
      shF[6] = iPt.x;
      shF[7] = iPt.y;
      shF[8] = iPt.z;
      col = trace(reflectRay, shI, shF);
      //col = trace(iPt, reflectRay, shI, shF);
      if (col->time >= TOLERANCE) {
         reflectClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * reflectScale, n1, dropoff, threadNum, depth - 1, shI, shF);
      }
      delete(col);
   }

   time = glm::length(iPt - start);
   float dropoffCalc = pow(dropoff, time);
   clr.x += (absorbClr.x + reflectClr.x + refractClr.x) * dropoffCalc;
   clr.y += (absorbClr.y + reflectClr.y + refractClr.y) * dropoffCalc;
   clr.z += (absorbClr.z + reflectClr.z + refractClr.z) * dropoffCalc;
   
	return clr;
}
//}*/
                  
glm::vec3 RayTracer::findReflect(glm::vec3 ray, glm::vec3 normal, SceneObject* obj) {
   glm::vec3 reflectRay;
   
   reflectRay = ray + (2.0f*normal*(glm::dot(normal, -ray)));
   reflectRay = glm::normalize(reflectRay);
   
   return reflectRay;
}

glm::vec3 RayTracer::findRefract(glm::vec3 ray, glm::vec3 normalI, SceneObject* obj, float n1, float* n2, float* R, float* dropoff) {
   glm::vec3 refractRay, normal = normalI;
   float dots1, R0, sroot, innersqr;
   
   //Determine object-ray status
   dots1 = glm::dot(-ray, normal);
   if (dots1 < 0.0f) { //Exitting
      *n2 = 1.0f; //Assume no refract object collision
      *dropoff = 1.0f;
      normal *= -1.0f;
      dots1 = glm::dot(-ray, normal);
   } else { //Entering
      *n2 = obj->indexRefraction;
      *dropoff = obj->dropoff;
   }
   
   sroot = 1.0f - ((n1 / *n2) * (n1 / *n2) * (1.0f - (dots1 * dots1)));
   if (sroot < 0.0f) { //Total internal reflection check
      *R = 1.0f;
   } else {
      //Schlick Overhead
      R0 = (n1 - *n2) / (n1 + *n2);
      R0 *= R0;
      
      innersqr = 1.0f - dots1;
      innersqr = pow(innersqr, 5);
      *R = R0 + ((1.0f - R0) * innersqr);
      
      refractRay = ((n1 / *n2) * (ray + (normal * dots1))) - (normal * sqrt(sroot));
      refractRay = glm::normalize(refractRay);
   }
   
   return refractRay;
}
