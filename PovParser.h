/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "glm/gtx/string_cast.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <algorithm>

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
      void ObjToPov(string filename);
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
      void parseTriangle(stringstream& buffer, int norms);
      void parseCone(stringstream& buffer);
      void parseBox(stringstream& buffer);
      void parseGW(stringstream& buffer);
      void parseObj(stringstream& buffer);
      
      //Sub-Parser Stuff
      void parseObjProps(stringstream& buffer, SceneObject* object);
      glm::vec4 parsePigment(stringstream& buffer);
      void parseFinish(stringstream& buffer, SceneObject* object);
      
      //Helper
      glm::vec3 parseEVect3(stringstream& buffer);
      glm::vec4 parseEVect4(stringstream& buffer);
      
      void locateOpenBrace(stringstream& buffer, string type);
      void locateCloseBrace(stringstream& buffer, string type);
      void locateComma(stringstream& buffer, string type);
      void locateOpenABrace(stringstream& buffer, string type);
      void locateCloseABrace(stringstream& buffer, string type);
};

#endif
