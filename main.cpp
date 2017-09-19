/*
   Cody Thompson
   Photon Mapping
   Image.cpp and Image.h made by Bob Sommers
*/

//Thx http://stackoverflow.com/questions/6978643/cuda-and-classes

#include <stdio.h>
#include <fstream>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <pthread.h>
#include <omp.h>
#include <time.h>

#include "SceneObject.h"
#include "Sphere.h"
#include "Triangle.h"
#include "Plane.h"
#include "PhotonMapper.h"
//#include "RayTracer.h"
#include "RayTracer.cuh"
#include "Image.h"
#include "structs.h"
//#include "KDTreeNode.h"
#include "KDTreeNode.cuh"
#include "Camera.h"
#include "Light.h"
#include "PovParser.h"
#include "GerstnerWave.h"
#include "OctTreeNode.h"
#include "QuadTreeNode.h"
#include "BiTreeNode.h"

#include "tracer.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp" //perspective, trans etc
#include "glm/gtc/type_ptr.hpp" //value_ptr

std::vector<SceneObject*> objects;

std::vector<Photon*> photonMap;
std::vector<Photon*> causticMap;
std::vector<Light*> lights;
float refCoef;
Camera* camera;
int imgheight, imgwidth;

using namespace std;

void setup(int argc, char* argv[], Pixel* pixels) {   
   std::vector<SceneObject*> tempObjects;
   
   lights.clear();
   objects.clear();
   photonMap.clear();
   causticMap.clear();
   
   PovParser *pparse;
   ifstream file;
   
   //int height, width;
   float left, right, top, bottom, u_s, v_s, w_s = -1.0f;
   glm::vec3 campos, rightV, upV, lookAt, tempV;
   glm::vec3 u_v, v_v, w_v;
   
   if (argc != 4) {
      perror("Required Format: trace <width> <height> <povray_file_name>");
      exit(1);
   }
   
   file.open(argv[3]);
   if (!file) {
      perror("Bad File");
      exit(1);
   }
   stringstream buffer;
   buffer.clear();
   buffer << file.rdbuf();
   file.close();
   
   pparse = new PovParser();
   pparse->parse(buffer);
   camera = pparse->getCamera();
   lights = pparse->getLights();
   tempObjects = pparse->getObjects();
   delete pparse;
   
   
   //cout << "Objects: " << objects.size() << endl;
   //pparse->printObjects();
   //exit(1);
   
   // Prepare objects (so far only grestner wave(s))
   for (uint i = 0; i < tempObjects.size(); i++) {
      if (tempObjects[i]->type == 5) { // Grestner Wave
         // Preparing: Putting triangles in vector to represent the wave surface
         GerstnerWave *GW = static_cast<GerstnerWave*>(tempObjects[i]);
         /*cout << GW->lb[0] << " " << GW->lb[1] << " " << GW->lb[2] << endl;
         cout << GW->ub[0] << " " << GW->ub[1] << " " << GW->ub[2] << endl;
         cout << "dirs" << endl;
         for (int i = 0; i < GW->direction.size(); i++) {
            cout << GW->direction[i].x() << " " << GW->direction[i].y() << " " << GW->direction[i].z() << endl;
         }
         cout << "amps" << endl;
         for (int i = 0; i < GW->amplitude.size(); i++) {
            cout << GW->amplitude[i] << endl;
         }
         cout << "wavelengths" << endl;
         for (int i = 0; i < GW->wavelength.size(); i++) {
            cout << GW->wavelength[i] << endl;
         }
         cout << "speedss" << endl;
         for (int i = 0; i < GW->speedPC.size(); i++) {
            cout << GW->speedPC[i] << endl;
         }
         cout << "freqs" << endl;
         for (int i = 0; i < GW->frequency.size(); i++) {
            cout << GW->frequency[i] << endl;
         }
         cout << "steeps" << endl;
         for (int i = 0; i < GW->steepness.size(); i++) {
            cout << GW->steepness[i] << endl;
         }
         cout << "ypos: " << GW->yPos << endl;
         cout << "waves: " << GW->waves << endl;*/
         //GW->toPovFileMesh("tempTriComp.pov", 0.05f, 2.0f);
         //std::terminate();
         GW->addTriangles(&tempObjects, 0.05f, 2.0f);
         //GOING AWAY SOON
         /*char *fileName = "tempTri.pov";
         ofstream meshFile;
         meshFile.open(fileName);
         Eigen::Vector3f a, b, c;
         Triangle *t;
         for (int i = 0; i < tempObjects.size(); i++) {
            if (tempObjects[i]->type == 2) {
               t = static_cast<Triangle*>(tempObjects[i]);
               a = t->a;
               b = t->b;
               c = t->c;
               
               meshFile << "triangle {\n";
               meshFile << "<" << a.x() << ", " << a.y() << ", " << a.z() << ">,\n";
               meshFile << "<" << b.x() << ", " << b.y() << ", " << b.z() << ">,\n";
               meshFile << "<" << c.x() << ", " << c.y() << ", " << c.z() << ">\n";
               meshFile << "pigment { color rgb <" << t->pigment.x() << ", " << t->pigment.y() << ", " << t->pigment.z() << ">}\n";
               meshFile << "finish {refraction " << t->refraction << " ior " << t->indexRefraction << " preflect " << t->photonReflectance << " prefract " << t->photonRefractance << "}\n";
               meshFile << "}\n";
            }
         }
         
         meshFile.close();
         //END
         std::terminate();*/
         cout << tempObjects.size() << endl;
      }
   }
   cout << tempObjects.size() << endl;
   for (uint i = 0; i < tempObjects.size(); i++) {
      if (tempObjects[i]->type == 1 || tempObjects[i]->type == 5) {
         if (tempObjects[i]->type == 1) {
            objects.push_back(tempObjects[i]);
         }
         if (tempObjects[i]->type == 5) delete tempObjects[i];
         tempObjects.erase(tempObjects.begin() + i);
         
         i--;
      }
   }
   /*for (int i = 0; i < tempObjects.size(); i++) {
      cout << tempObjects[i]->type << endl;
      tempObjects[i]->printObj();
   }*/
   /*for (int i = 0; i <tempObjects.size(); i++) {
      objects.push_back(tempObjects[i]->boundingBox);
      objects[objects.size() - 1]->pigment = Eigen::Vector4f(0.7, 0.7, 0.7, 1.0f);
   }*/
   
   QuadTreeNode* root;
   if (tempObjects.size() > 0) {
      cout << tempObjects.size() << endl;
      //cout << sizeof(OctTreeNode) << endl;
      root = new QuadTreeNode(tempObjects, tempObjects.size(), 0);
      cout << "Octree made" << endl;
      //printf("%f %f %f\n", root->boundingBox.minPt.x, root->boundingBox.minPt.y, root->boundingBox.minPt.z);
      //printf("%f %f %f\n", root->boundingBox.maxPt.x, root->boundingBox.maxPt.y, root->boundingBox.maxPt.z);
      //root->printObj();
      objects.push_back(root);
      cout << "QTREE LEN: " << root->treeLength() << endl;
   }
   
   //root->printObj();
   
   campos = camera->getPosition();
   rightV = camera->getRight();
   upV = camera->getUp();
   lookAt = camera->getLookAt();
   
   left = -(glm::length(rightV)) / 2.0;
   right = glm::length(rightV) / 2.0;
   bottom = -(glm::length(upV)) / 2.0;
   top = glm::length(upV) / 2.0;
   
   w_v = lookAt - campos;
   w_v = glm::normalize(w_v);
   w_v = -w_v;
   u_v = rightV;
   u_v = glm::normalize(u_v);
   v_v = upV;
   v_v = glm::normalize(v_v);
   
   //float dx = 1.0f / (float)imgwidth;
   //float dy = 1.0f / (float)imgheight;
   
   Pixel pix;
   pix.clr = glm::vec3(0.0f, 0.0f, 0.0f);
   for (int i = 0; i < imgwidth; i++) {
      for (int j = 0; j < imgheight; j++) {
         u_s = left + (right - left) * ((float(i) + 0.5f) / float(imgwidth));
         v_s = bottom + (top - bottom) * ((float(j) + 0.5f) / float(imgheight));
         pix.pt = (u_s * u_v) + (v_s * v_v) + (w_s * w_v);
         pixels[i*imgheight + j] = pix;
      }
   }
   
   
   //Grestner Wave Addition
   /*GerstnerWave* gwave = new GerstnerWave(0.1f, 3.0f, 0.1f, Eigen::Vector2f(1.0f, 0.0f), Eigen::Vector2f(-4.0f, -14.0f), Eigen::Vector2f(4.0f, 0.0f), 0.0f);
   //gwave->addWave(0.05f, 2.0f, 0.1f, Eigen::Vector2f(0.0f, 1.0f));
   Eigen::Vector2f direc = Eigen::Vector2f(1.0f, 1.0f);
   direc.normalize();
   gwave->addWave(0.05f, 2.0f, 0.1f, direc);
   gwave->pigment = Eigen::Vector4f(1.0f, 1.0f, 1.0f, 1.0f);
   gwave->refraction = 1.0f;
   gwave->indexRefraction = 1.33f;
   gwave->photonReflectance = 0.0f;
   gwave->photonRefractance = 1.0f;
   //objects.push_back(gwave);
   gwave->toPovFileMesh("wave-refract5.pov", 0.05f, 2.0f);
   std::terminate();*/
}   

//__attribute__ ((target(mic)))

int main(int argc, char* argv[]) {   

   // make a 640x480 image (allocates buffer on the heap)
   stringstream argstuff;
   argstuff << argv[1];
   argstuff >> imgwidth;
   argstuff.clear();
   argstuff << argv[2];
   argstuff >> imgheight;
   
   Pixel* pixels;
   pixels = new Pixel[imgwidth * imgheight];
   
   Image* img = new Image(imgwidth, imgheight);
   
   setup(argc, argv, pixels);
   printf("TYPE %d\n", (&(objects[0]))[0]->type);
   for (int i = 0; i < objects.size(); i++) {
      if (!objects[i]) printf("FUCK %d\n", i);
   }
   KDTreeNode* kd = new KDTreeNode();
   //printf("uhhhhh444 %f %f %f\n", lights[0]->getPosition().x, lights[0]->getPosition().y, lights[0]->getPosition().z);
   PhotonMapper* pm = new PhotonMapper(lights, objects);
   //printf("uhhhhh333 %f %f %f\n", pm->lights[0]->getPosition().x, pm->lights[0]->getPosition().y, pm->lights[0]->getPosition().z);
   cout << "Building Global Photon Map... " << endl;
   pm->buildGlobalMap();
   cout << "Building Caustic Photon Map(s)... " << endl;
   //pm->buildCausticMap();
   cout << "Done!" << endl;
   cout << photonMap.size() << endl;
   cout << GLOBALPHOTONS << endl;
   photonMap = pm->globalPhotons;
   causticMap = pm->causticPhotons;
   //causticMap.clear();
   int scount = 0;
   for (uint i = 0; i < photonMap.size(); i++) {
      if (photonMap[i]->type == 2) scount++;
   }
   cout << "Shadow Photons: " << scount << endl;
   cout << "Building Global KD Tree... " << endl;
   KDTreeNode *root = kd->buildKDTree(photonMap, -1);
   cout << "Building Cautic KD Tree(s)... " << endl;
   KDTreeNode *rootC1 = kd->buildKDTree(causticMap, -1);
   cout << "Done!" << endl;
   
   cout << "Global Photon Map Size: " << photonMap.size() << endl;
   cout << "Caustic Photon Map Size: " << causticMap.size() << endl;
   cout << "Global Tree size: " << root->Treesize() << endl;
   cout << "Caustic Tree size: " << rootC1->Treesize() << endl;
   
   //Start CUDA stuff
   glm::vec3 cPos = camera->getPosition();
   RayTracer* raytrace = new RayTracer(&lights, &objects, photonMap.size(), causticMap.size(), root, NULL);
   time_t startTime, endTime;
   //time(&startTime);
   int currentImgInd;
   
   RayTraceOnDevice(imgwidth, imgheight, pixels, objects, camera, root, rootC1, &startTime);
   
   
   
   /*for (int i = 0; i < imgwidth; i++) {
      //if (i < 80) {
      //cout << "i: " << i << endl;
      Collision* col;
      glm::vec3 ray, tempColor;
      bool unit = false;
      for (int j = 0; j < imgheight; j++) {
         //if (j == 50) {
         currentImgInd = i * imgheight + j;
         ray = pixels[currentImgInd].pt;// - cPos;
         //ray[0] *= (float)imgwidth / (float)imgheight;
         ray = glm::normalize(ray);
         //pixels[i][j].clr = calcRadiance(intersectPt, pixels[i][j].pt, ray, normal, col, root, rootC1, 2, 1.0, false);
         unit = false;
         if (i == imgwidth / 2 && j == imgheight / 2) unit = true;
         col = raytrace->trace(cPos, ray, unit);
         
         if (col->time > TOLERANCE) {
            pixels[currentImgInd].clr = raytrace->calcRadiance(cPos, cPos + ray * col->time, col->object, unit, 1.0f, 1.33f, 0.95f, 1); //Cam must start in air
            //tempColor = col->object->getNormal(col->object, cPos + ray * col->time, 2.0f);
            //pixels[currentImgInd].clr.x = tempColor.x * 0.5f + 0.5f;
            //pixels[currentImgInd].clr.y = tempColor.y * 0.5f + 0.5f;
            //pixels[currentImgInd].clr.z = tempColor.z * 0.5f + 0.5f;
         }
         else {
            pixels[currentImgInd].clr.x = pixels[currentImgInd].clr.y = pixels[currentImgInd].clr.z = 1.0f;
         }
         //cout << "PIXCOL: " << pixels[i][j].clr.x << " " << pixels[i][j].clr.y << " " << pixels[i][j].clr.z << endl;
         //}
      }
      //}
   }*/
   time(&endTime);
   cout << endTime - startTime << " seconds\n";
   //cout << planes[0].TLpt.x() << " " << planes[0].TLpt.y() << " " << planes[0].TLpt.z() << endl;
   //cout << planes[0].BRpt.x() << " " << planes[0].BRpt.y() << " " << planes[0].BRpt.z() << endl;
   //int currentImgInd;
   // set a square to be the color above
   for (int i=0; i < imgwidth; i++) {
      for (int j=0; j < imgheight; j++) {
         currentImgInd = i * imgheight + j;
         //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
         pixels[currentImgInd].clr.x = std::min(double(pixels[currentImgInd].clr.x), 1.0);
         pixels[currentImgInd].clr.y = std::min(double(pixels[currentImgInd].clr.y), 1.0);
         pixels[currentImgInd].clr.z = std::min(double(pixels[currentImgInd].clr.z), 1.0);
         img->pixel(i, j, pixels[currentImgInd].clr);
      }
   }
   cout << "oh" << endl;
   cout << imgwidth * imgheight << endl;
   delete[] pixels;
   
   cout << "yo" << endl;
   cout << objects.size() << endl;
   //cout << ((OctTreeNode*)objects[0])->treeLength() << endl;
   for (uint i = 0; i < objects.size(); i++) {
      //cout << "so uh" << endl;
      //cout << i << endl;
      //if (objects[i]->type == 7) delete objects[i];
      cout << objects[i]->type << endl;
      delete objects[i];
      //cout << objects[i]->type << endl;
      //cout << "can you delete this?" << endl;
   }
   cout << "here right" << endl;
   
   if (kd) delete kd;
   cout << "once more" << endl;
   if (pm) delete pm;
   cout << "pinpointing again" << endl;
   if (root) delete root;
   cout << "pinpointing above prob" << endl;
   if (rootC1) delete rootC1;
   
   cout << "pinpointing" << endl;
   /*for (uint i = 0; i < photonMap.size(); i++) {
      delete photonMap[i];
   }
   photonMap.clear();*/
   //delete photonMap;
   
   /*for (uint i = 0; i < causticMap.size(); i++) {
      delete causticMap[i];
   }
   causticMap.clear();*/
   //delete causticMap;
   /*cout << "LIGHTS: " << lights.size() << endl;*/
   for (uint i = 0; i < lights.size(); i++) {
      delete lights[i];
   }
   lights.clear();
   //delete lights;
   if (camera) delete camera;
   // write the targa file to disk
   img->WriteTga(const_cast<char*>(reinterpret_cast<const char*>("awesome.tga")), true);
   
   if (img) delete(img);
   
   // true to scale to max color, false to clamp to 1.0
   /*
   int i;
   Triangle t(glm::vec3(1.0,1.0,1.0), glm::vec3(1.0,1.0,1.0), glm::vec3(1.0,1.0,1.0));
   OctTreeNode ot;
   ot.type = 5;
   Triangle ts[2];
   cout << "Int size: " << sizeof(i) << endl;
   cout << "SO size: " << sizeof(SceneObject) << endl;
   cout << "Triangle size: " << sizeof(Triangle) << endl;
   //cout << "Triangle instance size: " << sizeof(t) << endl;
   cout << "Box size: " << sizeof(Box) << endl;
   cout << "OctTreeNode size: " << sizeof(OctTreeNode) << endl;
   
   memcpy(ts, &t, sizeof(t));
   memcpy(ts + 1, &ot, sizeof(ot));
   
   cout << "First Obj Type: " << ts[0].type << endl;
   cout << "Second Obj Type: " << ts[1].type << endl;
   OctTreeNode *ot2 = (OctTreeNode*)(ts + 1);
   cout << "OT2 type: " << ot2->type << endl;
   */
   /*cout << "OBJ SIZE: " << objects.size() << endl;
   for (int i = 0; i < objects.size(); i++) {
      cout << objects[i]->type << endl;
   }*/
}
