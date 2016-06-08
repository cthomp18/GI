/*
   Cody Thompson
   Photon Mapping
   Image.cpp and Image.h made by Bob Sommers
*/


#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <Eigen/Geometry>
#include <Eigen/Dense>
#include <Eigen/Sparse>

#include "SceneObject.h"
#include "Sphere.h"
#include "Plane.h"
#include "PhotonMapper.h"
#include "RayTracer.h"
#include "Image.h"
#include "structs.h"
#include "KDTreeNode.h"
#include "Camera.h"
#include "Light.h"
#include "PovParser.h"
#include "GerstnerWave.h"
#include "BVHNode.h"

std::vector<SceneObject*> objects;

std::vector<Photon*> photonMap;
std::vector<Photon*> causticMap;
std::vector<Light*> lights;
float refCoef;
Camera* camera;
int imgheight, imgwidth;

using namespace std;

void setup(int argc, char* argv[], Pixel** pixels) {   
   std::vector<SceneObject*> tempObjects;
   
   lights.clear();
   objects.clear();
   photonMap.clear();
   causticMap.clear();
   
   PovParser *pparse;
   ifstream file;
   
   int height, width;
   float left, right, top, bottom, u_s, v_s, w_s = -1.0f;
   Eigen::Vector3f campos, rightV, upV, lookAt, tempV;
   Eigen::Vector3f u_v, v_v, w_v;
   
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
   //cout << "Objects: " << objects.size() << endl;
   //pparse->printObjects();
   //exit(1);
   
   for (int i = 0; i < tempObjects.size(); i++) {
      if (tempObjects[i]->type == 1) {
         objects.push_back(tempObjects[i]);
         tempObjects.erase(tempObjects.begin() + i);
         
         i--;
      }
   }
   /*for (int i = 0; i <tempObjects.size(); i++) {
      objects.push_back(tempObjects[i]->boundingBox);
      objects[objects.size() - 1]->pigment = Eigen::Vector4f(0.7, 0.7, 0.7, 1.0f);
   }*/
   BVHNode* root;
   if (tempObjects.size() > 0) {
      root = new BVHNode(tempObjects, 0, tempObjects.size());
      cout << "BVH made" << endl;
      objects.push_back(root);
   }
   
   campos = camera->getPosition();
   rightV = camera->getRight();
   upV = camera->getUp();
   lookAt = camera->getLookAt();
   
   left = -(rightV.norm()) / 2.0;
   right = rightV.norm() / 2.0;
   bottom = -(upV.norm()) / 2.0;
   top = upV.norm() / 2.0;
   
   w_v = lookAt - campos;
   w_v.normalize();
   w_v = -w_v;
   u_v = rightV;
   u_v.normalize();
   v_v = upV;
   v_v.normalize();
   
   float dx = 1.0f / (float)imgwidth;
   float dy = 1.0f / (float)imgheight;  
   
   Pixel pix;
   for (int i = 0; i < imgwidth; i++) {
      for (int j = 0; j < imgheight; j++) {
         u_s = left + (right - left) * ((float(i) + 0.5f) / float(imgwidth));
         v_s = bottom + (top - bottom) * ((float(j) + 0.5f) / float(imgheight));
         pix.pt = (u_s * u_v) + (v_s * v_v) + (w_s * w_v);
         pixels[i][j] = pix;
      }
   }
   
   //Grestner Wave Addition
   GerstnerWave* gwave = new GerstnerWave(0.1f, 3.0f, 0.1f, Eigen::Vector2f(1.0f, 0.0f), Eigen::Vector2f(-4.0f, -14.0f), Eigen::Vector2f(4.0f, 0.0f), -1.0f);
   //gwave->addWave(0.05f, 2.0f, 0.1f, Eigen::Vector2f(0.0f, 1.0f));
   Eigen::Vector2f direc = Eigen::Vector2f(1.0f, 1.0f);
   direc.normalize();
   gwave->addWave(0.05f, 2.0f, 0.1f, direc);
   gwave->pigment = Eigen::Vector4f(1.0f, 1.0f, 1.0f, 1.0f);
   gwave->refraction = 0.0f;
   gwave->indexRefraction = 1.33f;
   gwave->photonReflectance = 0.0f;
   gwave->photonRefractance = 1.0f;
   //objects.push_back(gwave);
   gwave->toPovFileMesh("wave-refract3.pov", 0.05f, 2.0f);
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
   
   Pixel** pixels;
   pixels = new Pixel *[imgwidth];
   for (int i = 0; i < imgwidth; i++) {
      pixels[i] = new Pixel[imgheight];
   }
   
   setup(argc, argv, pixels);
   KDTreeNode* kd = new KDTreeNode();
   Image img(imgwidth, imgheight);
   PhotonMapper* pm = new PhotonMapper(lights, objects);
   //cout << "Building Global Photon Map... " << endl;
   //pm->buildGlobalMap();
   //cout << "Building Caustic Photon Map(s)... " << endl;
   //pm->buildCausticMap();
   //cout << "Done!" << endl;
   //cout << photonMap.size() << endl;
   //cout << GLOBALPHOTONS << endl;
   photonMap = pm->globalPhotons;
   causticMap = pm->causticPhotons;
   //causticMap.clear();
   //int scount = 0;
   //for (int i = 0; i < photonMap.size(); i++) {
   //   if (photonMap[i]->type == 2) scount++;
   //}
   //cout << "Shadow Photons: " << scount << endl;
   //cout << "Building Global KD Tree... " << endl;
   KDTreeNode *root = kd->buildKDTree(photonMap, NULL);
   //cout << "Building Cautic KD Tree(s)... " << endl;
   KDTreeNode *rootC1 = kd->buildKDTree(causticMap, NULL);
   //cout << "Done!" << endl;
   
   //cout << "Global Photon Map Size: " << photonMap.size() << endl;
   //cout << "Caustic Photon Map Size: " << causticMap.size() << endl;
   //cout << "Global Tree size: " << kd->Treesize(root) << endl;
   //cout << "Caustic Tree size: " << kd->Treesize(rootC1) << endl;
   
   Eigen::Vector3f cPos = camera->getPosition();
   RayTracer* raytrace = new RayTracer(lights, objects, photonMap, causticMap, root, rootC1);
   #pragma omp parallel for
   for (int i = 0; i < imgwidth; i++) {
      //cout << "i: " << i << endl;
      Collision* col;
      Eigen::Vector3f ray;
      bool unit = false;
      for (int j = 0; j < imgheight; j++) {
      
         ray = pixels[i][j].pt;// - cPos;
         //ray[0] *= (float)imgwidth / (float)imgheight;
         ray.normalize();
         //pixels[i][j].clr = calcRadiance(intersectPt, pixels[i][j].pt, ray, normal, col, root, rootC1, 2, 1.0, false);
         unit = false;
         if (i == imgwidth / 2 && j == imgheight / 2) unit = true;
         //col = raytrace->trace(cPos, ray, unit);
         
         //if (col->time > TOLERANCE) pixels[i][j].clr = raytrace->calcRadiance(cPos, cPos + ray * col->time, col->object, unit, 1.0f, 1.33f, 5); //Cam must start in air
         //else {
            pixels[i][j].clr.r = pixels[i][j].clr.g = pixels[i][j].clr.b = 0.0f;
         //}
         //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
      }
   }
   //cout << planes[0].TLpt.x() << " " << planes[0].TLpt.y() << " " << planes[0].TLpt.z() << endl;
   //cout << planes[0].BRpt.x() << " " << planes[0].BRpt.y() << " " << planes[0].BRpt.z() << endl;
  // set a square to be the color above
  for (int i=0; i < imgwidth; i++) {
    for (int j=0; j < imgheight; j++) {
      //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
      pixels[i][j].clr.r = std::min(pixels[i][j].clr.r, 1.0);
      pixels[i][j].clr.g = std::min(pixels[i][j].clr.g, 1.0);
      pixels[i][j].clr.b = std::min(pixels[i][j].clr.b, 1.0);
      img.pixel(i, j, pixels[i][j].clr);
    }
  }

  // write the targa file to disk
  img.WriteTga((char *)"awesome.tga", true); 
  // true to scale to max color, false to clamp to 1.0

}
