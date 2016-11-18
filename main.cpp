/*
   Cody Thompson
   Photon Mapping
   Image.cpp and Image.h made by Bob Sommers
*/


#include <stdio.h>
#include <fstream>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <Eigen/Geometry>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <pthread.h>
#include <omp.h>
#include <time.h>

#include "SceneObject.h"
#include "Sphere.h"
#include "Triangle.h"
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
#include "QuadTreeNode.h"

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
   
   // Prepare objects (so far only grestner wave(s))
   for (int i = 0; i < tempObjects.size(); i++) {
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
   for (int i = 0; i < tempObjects.size(); i++) {
      if (tempObjects[i]->type == 1 || tempObjects[i]->type == 5) {
         objects.push_back(tempObjects[i]);
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
      root = new QuadTreeNode(tempObjects, tempObjects.size(), 0);
      cout << "Quad Tree made" << endl;
      //root->printObj();
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
   
   Pixel** pixels;
   pixels = new Pixel *[imgwidth];
   for (int i = 0; i < imgwidth; i++) {
      pixels[i] = new Pixel[imgheight];
   }
   
   setup(argc, argv, pixels);

   KDTreeNode* kd = new KDTreeNode();
   //Image* img = new Image(imgwidth, imgheight);
   PhotonMapper* pm = new PhotonMapper(lights, objects);
   cout << "Building Global Photon Map... " << endl;
   pm->buildGlobalMap();
   cout << "Building Caustic Photon Map(s)... " << endl;
   pm->buildCausticMap();
   cout << "Done!" << endl;
   cout << photonMap.size() << endl;
   cout << GLOBALPHOTONS << endl;
   photonMap = pm->globalPhotons;
   causticMap = pm->causticPhotons;
   //causticMap.clear();
   int scount = 0;
   for (int i = 0; i < photonMap.size(); i++) {
      if (photonMap[i]->type == 2) scount++;
   }
   cout << "Shadow Photons: " << scount << endl;
   cout << "Building Global KD Tree... " << endl;
   KDTreeNode *root = kd->buildKDTree(photonMap, NULL);
   cout << "Building Cautic KD Tree(s)... " << endl;
   KDTreeNode *rootC1 = kd->buildKDTree(causticMap, NULL);
   cout << "Done!" << endl;
   
   cout << "Global Photon Map Size: " << photonMap.size() << endl;
   cout << "Caustic Photon Map Size: " << causticMap.size() << endl;
   cout << "Global Tree size: " << kd->Treesize(root) << endl;
   cout << "Caustic Tree size: " << kd->Treesize(rootC1) << endl;
   
   Eigen::Vector3f cPos = camera->getPosition();
   RayTracer* raytrace = new RayTracer(lights, objects, photonMap, causticMap, root, rootC1);
   time_t startTime, endTime;
   time(&startTime);
   
   omp_set_num_threads(16);
   #pragma omp parallel for
   for (int i = 0; i < imgwidth; i++) {
      //cout << "i: " << i << endl;
      Collision* col;
      Eigen::Vector3f ray, tempColor;
      bool unit = false;
      for (int j = 0; j < imgheight; j++) {
      
         ray = pixels[i][j].pt;// - cPos;
         //ray[0] *= (float)imgwidth / (float)imgheight;
         ray.normalize();
         //pixels[i][j].clr = calcRadiance(intersectPt, pixels[i][j].pt, ray, normal, col, root, rootC1, 2, 1.0, false);
         unit = false;
         if (i == imgwidth / 2 && j == imgheight / 2) unit = true;
         col = raytrace->trace(cPos, ray, unit);
         
         if (col->time > TOLERANCE) {
            pixels[i][j].clr = raytrace->calcRadiance(cPos, cPos + ray * col->time, col->object, unit, 1.0f, 1.33f, 0.95f, 5); //Cam must start in air
            /*tempColor = col->object->getNormal(cPos + ray * col->time, 2.0f);
            pixels[i][j].clr.r = tempColor.x() * 0.5f + 0.5f;
            pixels[i][j].clr.g = tempColor.y() * 0.5f + 0.5f;
            pixels[i][j].clr.b = tempColor.z() * 0.5f + 0.5f;*/
         }
         else {
            pixels[i][j].clr.r = pixels[i][j].clr.g = pixels[i][j].clr.b = 0.0f;
         }
         //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
      }
   }
   time(&endTime);
   cout << endTime - startTime << " seconds\n";
   //cout << planes[0].TLpt.x() << " " << planes[0].TLpt.y() << " " << planes[0].TLpt.z() << endl;
   //cout << planes[0].BRpt.x() << " " << planes[0].BRpt.y() << " " << planes[0].BRpt.z() << endl;
  // set a square to be the color above
  /*for (int i=0; i < imgwidth; i++) {
    for (int j=0; j < imgheight; j++) {
      //cout << "PIXCOL: " << pixels[i][j].clr.r << " " << pixels[i][j].clr.g << " " << pixels[i][j].clr.b << endl;
      pixels[i][j].clr.r = std::min(pixels[i][j].clr.r, 1.0);
      pixels[i][j].clr.g = std::min(pixels[i][j].clr.g, 1.0);
      pixels[i][j].clr.b = std::min(pixels[i][j].clr.b, 1.0);
      img->pixel(i, j, pixels[i][j].clr);
    }
  }*/

  // write the targa file to disk
  //img->WriteTga((char *)"awesome.tga", true); 
  // true to scale to max color, false to clamp to 1.0

}
