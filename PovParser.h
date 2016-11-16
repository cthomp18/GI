/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>

#include "Camera.h"
#include "Light.h"
#include "SceneObject.h"
#include "Sphere.h"
#include "Plane.h"
#include "Cone.h"
#include "Triangle.h"
#include "Box.h"
#include "GerstnerWave.h"

using namespace std;

#ifndef __POVPARSE_H__
#define __POVPARSE_H__

class PovParser {
   public:
      PovParser();
      ~PovParser();
      
      Camera* getCamera();
      std::vector<Light*> getLights();
      std::vector<SceneObject*> getObjects();
      
      void parse(stringstream& buffer);
      //Print
      void printObjects();
      
   private:
      //Variables
      Camera* camera;
      std::vector<Light*> lights;
      std::vector<SceneObject*> objects;
      
      //Main Things
      void parseCamera(stringstream& buffer);
      void parseLight(stringstream& buffer);
      
      //Objects
      void parseSphere(stringstream& buffer);
      void parsePlane(stringstream& buffer);
      void parseTriangle(stringstream& buffer);
      void parseCone(stringstream& buffer);
      void parseBox(stringstream& buffer);
      void parseGW(stringstream& buffer);
      
      //Sub-Parser Stuff
      void parseObjProps(stringstream& buffer, SceneObject* object);
      Eigen::Vector4f parsePigment(stringstream& buffer);
      void parseFinish(stringstream& buffer, SceneObject* object);
      
      //Helper
      Eigen::Vector3f parseEVect3(stringstream& buffer);
      Eigen::Vector4f parseEVect4(stringstream& buffer);
      
      void locateOpenBrace(stringstream& buffer, string type);
      void locateCloseBrace(stringstream& buffer, string type);
      void locateComma(stringstream& buffer, string type);
      void locateOpenABrace(stringstream& buffer, string type);
      void locateCloseABrace(stringstream& buffer, string type);
};

#endif
