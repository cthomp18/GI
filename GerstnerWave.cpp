/*
   Cody Thompson
   Photon Mapping
*/

#include "GerstnerWave.h"
using namespace std;
GerstnerWave::GerstnerWave(float a, float w, float s, glm::vec3 d, glm::vec3 lowerleft, glm::vec3 upperright, float yPosition) : SceneObject() {
   amplitude.clear();
   wavelength.clear();
   frequency.clear();
   speedPC.clear();
   direction.clear();
   steepness.clear();
   
   amplitude.push_back(a);
   wavelength.push_back(w);
   frequency.push_back(sqrt(9.81f * ((2.0f * M_PI) / w)));
   speedPC.push_back(s * sqrt(9.81f * ((2.0f * M_PI) / w)));
   d = glm::normalize(d);
   direction.push_back(d);
   steepness.push_back(1.0f / (sqrt(9.81f * ((2.0f * M_PI) / w)) * a * 2.0f));
   lb = lowerleft;
   ub = upperright;
   yPos = yPosition;
   
   waves = 1;
}

GerstnerWave::GerstnerWave() : SceneObject() {
   amplitude.clear();
   wavelength.clear();
   frequency.clear();
   speedPC.clear();
   direction.clear();
   steepness.clear();

   lb = ub = glm::vec3(0.0f,0.0f,0.0f);
   steepness.clear();
   yPos = 0.0f;
   
   waves = 0;
}

GerstnerWave::~GerstnerWave() {}

// Not using this function anymore btw

float GerstnerWave::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   /*float t = -1.0f, tAccrue = 0.0f;
   
   //Ray Marching Boys
   
   Eigen::Vector3f pt0 = start; //Current point
   Eigen::Vector3f pt1 = start; //Next point
   Eigen::Vector3f ptW = getPoint(pt1.x(), pt1.z(), time); //Point on wave with same x, z (i think)
   Eigen::Vector3f normal; //Normal of said point on wave
   float step = 0.01f; //Current step (May or may not go through wave if (near) parallel to y plane)
   
   float povertwo = M_PI / 2.0f;
   
   while (pt1.y() - ptW.y() > TOLERANCE) {// (|| abs(pt1.x() - ptW.x()) > TOLERANCE || abs(pt1.z() - ptW.z()) > TOLERANCE)
      if (tAccrue > 22.0f) break;
      //std::cout << "ptW: " << ptW.x() << " " << ptW.y() << " " << ptW.z() << " pt1: " << pt1.x() << " " << pt1.y() << " " << pt1.z() << std::endl;
      //std::cout << "dotthing: " << normal.dot(pt1 - ptW) << std::endl;
      //std::cout << "tAcc " << tAccrue << std::endl;
      if (normal.dot(pt1 - ptW) < TOLERANCE || pt1.y() - ptW.y() < TOLERANCE) { //If pt1 on the other side of the wave
         pt1 = pt0;
         tAccrue -= step;
         step /= 4.0f;
      } else {
         tAccrue += step;
      }
      
      pt0 = pt1;
      pt1 = pt0 + (ray * step);
      ptW = getPoint(pt1.x(), pt1.z(), time);
      normal = getNormal(pt1, time);
      //std::cout << tAccrue << std::endl;
   }
   
   if (pt1.y() - ptW.y() <= TOLERANCE) { t = tAccrue; }
   return t;*/
   return -1.0f;
}

glm::vec3 GerstnerWave::getNormal(glm::vec3 iPt, float time) {
   glm::vec3 normal = glm::vec3(0.0f, 1.0f, 0.0f);
   float wa, wdpt, coswa;
   
   for (int i = 0; i < waves; i++) {
      wa = frequency[i] * amplitude[i];
      wdpt = glm::dot(frequency[i] * glm::vec3(direction[i].x, 0.0f, direction[i].z), iPt) + (time * speedPC[i]);
      coswa = wa * cos(wdpt);
      normal -= glm::vec3(direction[i].x * coswa, (steepness[i] * wa * sin(wdpt)), direction[i].z * coswa);
   }
   normal = glm::normalize(normal);
   
   return normal;
}

glm::vec3 GerstnerWave::getPoint(float x, float z, float time) {
   glm::vec3 iPt = glm::vec3(x, 0.0f, z);
   float wdpt, qacos;
   
   for (int i = 0; i < waves; i++) {
      wdpt = glm::dot(frequency[i] * direction[i], glm::vec3(x, 0.0f, z)) + (time * speedPC[i]);
      qacos = steepness[i] * amplitude[i] * cos(wdpt);
      iPt += glm::vec3(qacos * direction[i].x, (amplitude[i] * sin(wdpt)) + yPos, qacos * direction[i].z);
   }
   
   return iPt;
}

void GerstnerWave::addWave(float a, float w, float s, glm::vec3 d) {
   amplitude.push_back(a);
   wavelength.push_back(w);
   frequency.push_back(sqrt(9.81f * ((2.0f * M_PI) / w)));
   speedPC.push_back(s * sqrt(9.81f * ((2.0f * M_PI) / w)));
   d = glm::normalize(d);
   direction.push_back(d);
   steepness.push_back(1.0f / (sqrt(9.81f * ((2.0f * M_PI) / w)) * a * float(waves + 1)));
   
   for (int i = 0; i < waves; i++) {
      steepness[i] *= float(waves);
      steepness[i] /= float(waves + 1);
   }
   
   waves++;
}

void GerstnerWave::addTriangles(std::vector<SceneObject*> *objects, float step, float time) {
   float depth = ub[2] - lb[2], width = ub[0] - lb[0];
   int matDepth = depth / step, matWidth = width / step;
   
   glm::vec3 wavePts[matDepth][matWidth];
   glm::vec3 waveNorms[matDepth][matWidth];
  
   //FILL MATS
   for (int i = 0; i < matDepth; i++) {
      for (int j = 0; j < matWidth; j++) {
         wavePts[i][j] = getPoint((j * step) + lb[0], (i * step) + lb[2], time);
         waveNorms[i][j] = getNormal(wavePts[i][j], time);
      }
   }
   
   //WRITE
   //EACH ITERATION = 2 TRIANGLES
   //SQUARES
   glm::vec3 a, b, c;
   Triangle *triangle;
   cout << matDepth << endl;
   cout << matWidth << endl;
   for (int i = 0; i < matDepth - 1; i++) {
      for (int j = 0; j < matWidth - 1; j++) {
         a = wavePts[i][j];
         b = wavePts[i+1][j];
         c = wavePts[i][j+1];
         
         triangle = new Triangle(a, b, c, true);
         triangle->aNor = waveNorms[i][j];
         triangle->bNor = waveNorms[i+1][j];
         triangle->cNor = waveNorms[i][j+1];
         
         triangle->pigment = pigment;
         triangle->refraction = refraction;
         triangle->indexRefraction = indexRefraction;
         triangle->photonReflectance = photonReflectance;
         triangle->photonRefractance = photonRefractance;
         triangle->dropoff = dropoff;
         triangle->type = 2;
         triangle->constructBB();
         
         objects->push_back(triangle);
         
         a = wavePts[i+1][j];
         b = wavePts[i+1][j+1];
         c = wavePts[i][j+1];
         
         triangle = new Triangle(a, b, c, true);
         triangle->aNor = waveNorms[i+1][j];
         triangle->bNor = waveNorms[i+1][j+1];
         triangle->cNor = waveNorms[i][j+1];
         
         triangle->pigment = pigment;
         triangle->refraction = refraction;
         triangle->indexRefraction = indexRefraction;
         triangle->photonReflectance = photonReflectance;
         triangle->photonRefractance = photonRefractance;
         triangle->dropoff = dropoff;
         triangle->type = 2;
         triangle->constructBB();
         
         objects->push_back(triangle);
      }
   }
   cout << objects->size() << endl;
}

void GerstnerWave::toPovFileMesh(char* fileName, float step, float time) {
   //GOING TO BUILD 2D MATRIX OF WAVE POINTS
   //WRITE INTO FILE TRIANGLES IN POV FORMAT
   
   float depth = ub[2] - lb[2], width = ub[0] - lb[0];
   int matDepth = depth / step, matWidth = width / step;
   
   glm::vec3 wavePts[matDepth][matWidth];
   glm::vec3 waveNorms[matDepth][matWidth];
   
   ofstream meshFile;
   meshFile.open(fileName);
   //myfile << "Writing this to a file.\n";
  
   //FILL MAT
   for (int i = 0; i < matDepth; i++) {
      for (int j = 0; j < matWidth; j++) {
         wavePts[i][j] = getPoint((j * step) + lb[0], (i * step) + lb[2], time);
         waveNorms[i][j] = getNormal(wavePts[i][j], time);
      }
   }
   
   //WRITE
   //EACH ITERATION = 2 TRIANGLES
   //SQUARES
   glm::vec3 a, b, c;
   for (int i = 0; i < matDepth - 1; i++) {
      for (int j = 0; j < matWidth - 1; j++) {
         a = wavePts[i][j];
         b = wavePts[i+1][j];
         c = wavePts[i][j+1];
         
         meshFile << "triangle {\n";
         meshFile << "<" << a.x << ", " << a.y << ", " << a.z << ">,\n";
         meshFile << "<" << b.x << ", " << b.y << ", " << b.z << ">,\n";
         meshFile << "<" << c.x << ", " << c.y << ", " << c.z << ">\n";
         meshFile << "pigment { color rgb <" << pigment.x << ", " << pigment.y << ", " << pigment.z << ">}\n";
         meshFile << "finish {refraction " << refraction << " ior " << indexRefraction << " preflect " << photonReflectance << " prefract " << photonRefractance << "}\n";
         meshFile << "}\n";
         
         a = wavePts[i+1][j];
         b = wavePts[i+1][j+1];
         c = wavePts[i][j+1];
         
         meshFile << "triangle {\n";
         meshFile << "<" << a.x << ", " << a.y << ", " << a.z << ">,\n";
         meshFile << "<" << b.x << ", " << b.y << ", " << b.z << ">,\n";
         meshFile << "<" << c.x << ", " << c.y << ", " << c.z << ">\n";
         meshFile << "pigment { color rgb <" << pigment.x << ", " << pigment.y << ", " << pigment.z << ">}\n";
         meshFile << "finish {refraction " << refraction << " ior " << indexRefraction << " preflect " << photonReflectance << " prefract " << photonRefractance << "}\n";
         meshFile << "}\n";
      }
   }
   
   meshFile.close();
}
