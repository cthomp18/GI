/*
   Cody Thompson
   Photon Mapping
*/

#include "GerstnerWave.h"
using namespace std;
GerstnerWave::GerstnerWave(float a, float w, float s, Eigen::Vector2f d, Eigen::Vector2f lowerleft, Eigen::Vector2f upperright, float yPosition) : SceneObject() {
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

   lb = ub = Eigen::Vector2f(0.0f,0.0f);
   steepness.clear();
   yPos = 0.0f;
   
   waves = 0;
}

GerstnerWave::~GerstnerWave() {}

float GerstnerWave::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   float t = -1.0f, tAccrue = 0.0f;
   
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
   return t;
}

Eigen::Vector3f GerstnerWave::getNormal(Eigen::Vector3f iPt, float time) {
   Eigen::Vector3f normal = Eigen::Vector3f(0.0f, 1.0f, 0.0f);
   float wa, wdpt, coswa;
   
   for (int i = 0; i < waves; i++) {
      wa = frequency[i] * amplitude[i];
      wdpt = (frequency[i] * Eigen::Vector3f(direction[i].x(), 0.0f, direction[i].y())).dot(iPt) + (time * speedPC[i]);
      coswa = wa * cos(wdpt);
      normal -= Eigen::Vector3f(direction[i].x() * coswa, (steepness[i] * wa * sin(wdpt)), direction[i].y() * coswa);
   }
   normal.normalize();
   
   return normal;
}

Eigen::Vector3f GerstnerWave::getPoint(float x, float z, float time) {
   Eigen::Vector3f iPt = Eigen::Vector3f(x, 0.0f, z);
   float wdpt, qacos;
   
   for (int i = 0; i < waves; i++) {
      wdpt = (frequency[i] * direction[i]).dot(Eigen::Vector2f(x, z)) + (time * speedPC[i]);
      qacos = steepness[i] * amplitude[i] * cos(wdpt);
      iPt += Eigen::Vector3f(qacos * direction[i].x(), (amplitude[i] * sin(wdpt)) + yPos, qacos * direction[i].y());
   }
   
   return iPt;
}

void GerstnerWave::addWave(float a, float w, float s, Eigen::Vector2f d) {
   amplitude.push_back(a);
   wavelength.push_back(w);
   frequency.push_back(sqrt(9.81f * ((2.0f * M_PI) / w)));
   speedPC.push_back(s * sqrt(9.81f * ((2.0f * M_PI) / w)));
   direction.push_back(d);
   steepness.push_back(1.0f / (sqrt(9.81f * ((2.0f * M_PI) / w)) * a * float(waves + 1)));
   
   for (int i = 0; i < waves; i++) {
      steepness[i] *= float(waves);
      steepness[i] /= float(waves + 1);
   }
   
   waves++;
}

void GerstnerWave::toPovFileMesh(char* fileName, float step, float time) {
   //GOING TO BUILD 2D MATRIX OF WAVE POINTS
   //WRITE INTO FILE TRIANGLES IN POV FORMAT
   
   float depth = ub[1] - lb[1], width = ub[0] - lb[0];
   int matDepth = depth / step, matWidth = width / step;
   
   Eigen::Vector3f wavePts[matDepth][matWidth];
   
   ofstream meshFile;
   meshFile.open(fileName);
   //myfile << "Writing this to a file.\n";
  
   //FILL MAT
   for (int i = 0; i < matDepth; i++) {
      for (int j = 0; j < matWidth; j++) {
         wavePts[i][j] = getPoint((j * step) + lb[0], (i * step) + lb[1], time);
      }
   }
   
   //WRITE
   //EACH ITERATION = 2 TRIANGLES
   //SQUARES
   Eigen::Vector3f a, b, c;
   for (int i = 0; i < matDepth - 1; i++) {
      for (int j = 0; j < matWidth - 1; j++) {
         a = wavePts[i][j];
         b = wavePts[i+1][j];
         c = wavePts[i][j+1];
         
         meshFile << "triangle {\n";
         meshFile << "<" << a.x() << ", " << a.y() << ", " << a.z() << ">,\n";
         meshFile << "<" << b.x() << ", " << b.y() << ", " << b.z() << ">,\n";
         meshFile << "<" << c.x() << ", " << c.y() << ", " << c.z() << ">\n";
         meshFile << "pigment { color rgb <" << pigment.x() << ", " << pigment.y() << ", " << pigment.z() << ">}\n";
         meshFile << "finish {refraction " << refraction << " ior " << indexRefraction << "}\n";
         meshFile << "}\n";
         
         a = wavePts[i+1][j];
         b = wavePts[i+1][j+1];
         c = wavePts[i][j+1];
         
         meshFile << "triangle {\n";
         meshFile << "<" << a.x() << ", " << a.y() << ", " << a.z() << ">,\n";
         meshFile << "<" << b.x() << ", " << b.y() << ", " << b.z() << ">,\n";
         meshFile << "<" << c.x() << ", " << c.y() << ", " << c.z() << ">\n";
         meshFile << "pigment { color rgb <" << pigment.x() << ", " << pigment.y() << ", " << pigment.z() << ">}\n";
         meshFile << "finish {refraction " << refraction << " ior " << indexRefraction << "}\n";
         meshFile << "}\n";
      }
   }
   
   meshFile.close();
}
