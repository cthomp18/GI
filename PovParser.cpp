/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

/*
SUPPORTS:
   Cameras
   Lights
   SceneObjects: Sphere, Box, Triangle, Plane, Cone
*/
   
#include "PovParser.h"

using namespace std;

PovParser::PovParser() {
   camera = NULL;
   lights.clear();
   objects.clear();
}

PovParser::~PovParser() {}

/***************GET-TERS***************/

Camera* PovParser::getCamera() {
   return camera;
}

std::vector<Light*> PovParser::getLights() {
   return lights;
}

std::vector<SceneObject*> PovParser::getObjects() {
   return objects;
}

/***************MAIN PARSER***************/

void PovParser::parse(stringstream& buffer) {
   string name = "", line = "";
   char curChar;
   while (buffer) {
      curChar = buffer.get();
      while (curChar == '\n' || curChar == '\r' || curChar == ' ' || curChar == '\0') curChar = buffer.get();
      if (!buffer) break;
      else buffer.unget();
      buffer >> name;
      if (name[0] == '/' && name[1] == '/') {
         line += name;
         while ((curChar = buffer.get()) != '\n' && curChar != '\r' && buffer) line += curChar;
         //cout << "Comment skipped: " << line << endl;
         line.clear();
         continue;
      }

      //cout << "------------" << endl;
      //cout << buffer.str() << endl;
      //cout << "------------" << endl;

      if (name == "camera") {
         parseCamera(buffer);
         //cout << "Parsed Camera" << endl;
      } else if (name == "light_source") {
         parseLight(buffer);
         //cout << "Parsed Light" << endl;
      } else if (name == "sphere") {
         parseSphere(buffer);
         //cout << "Parsed Sphere" << endl;
      } else if (name == "plane") {
         parsePlane(buffer);
         //cout << "Parsed Plane" << endl;
      } else if (name == "triangle") {
         parseTriangle(buffer);
      } else if (name == "cone") {
         parseCone(buffer);
      } else if (name == "box") {
         parseBox(buffer);
      } else if (name == "gerstner_wave") {
         parseGW(buffer);
      } else if (name == "\0") {
         cout << "good" << endl;
      } else {
         perror("Error - PovRay - Bad Name");
         cout << "Name Given: " << name << endl;
      }
   }
}

/***************CAMERA PARSING***************/

void PovParser::parseCamera(stringstream& buffer) {
   string name;
   char curChar;
   Eigen::Vector3f loc, up, right, lookat;
   locateOpenBrace(buffer, "Camera");
   while ((curChar = buffer.get()) != '}') { 
      if (!buffer || curChar == '{') {
         perror("Error - PovRay - Camera - Bad Format (No Closed Brace)");
         exit(1);
      }
      
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         buffer.unget();
         buffer >> name;
         name.erase(remove(name.begin(), name.end(), '\n'), name.end());
         name.erase(remove(name.begin(), name.end(), '\r'), name.end());
         
         if (name == "location") {
            loc = parseEVect3(buffer);
         } else if (name == "up") {
            up = parseEVect3(buffer);
         } else if (name == "right") {
            right = parseEVect3(buffer);
         } else if (name == "look_at") {
            lookat = parseEVect3(buffer);
         } else {
            perror("Error - PovRay - Camera - Bad Name");
            cout << "Name Given: " << name << endl;
            exit(1);
         }
      }
   }
   //cout << loc.x() << " " << loc.y() << " " << loc.z() << endl;
   camera = new Camera(loc, up, right, lookat);
}

/***************Light PARSING***************/

void PovParser::parseLight(stringstream& buffer) {
   string name;
   char curChar;
   Eigen::Vector3f lpos, lcol;
   
   locateOpenBrace(buffer, "Light");

   lpos = parseEVect3(buffer);
   
   buffer >> name;
   if (name != "color") {
      perror("Error - PovRay - Light - Bad Format (Color)");
      exit(1);
   }
   buffer >> name;
   if (name != "rgb") {
      perror("Error - PovRay - Light - Bad Format (Color)");
      exit(1);
   }
   
   lcol = parseEVect3(buffer);
   
   locateCloseBrace(buffer, "Light");
   
   lights.push_back(new Light(lpos, lcol));
}

/***************OBJECT PARSING***************/

void PovParser::parseSphere(stringstream& buffer) {
   Eigen::Vector3f loc;
   float rad;
   Sphere* sphere;
   
   locateOpenBrace(buffer, "Sphere");
   loc = parseEVect3(buffer);
   locateComma(buffer, "Sphere");
   buffer >> rad;
   
   sphere = new Sphere(loc, rad);
   sphere->type = 0;
   parseObjProps(buffer, sphere);
   sphere->constructBB();
   sphere->applyTransforms();
   
   objects.push_back(sphere);
}

void PovParser::parsePlane(stringstream& buffer) {
   Eigen::Vector3f normal;
   float distance;
   Plane* plane;

   locateOpenBrace(buffer, "Plane");
   normal = parseEVect3(buffer);
   locateComma(buffer, "Plane");
   buffer >> distance;
   
   plane = new Plane(normal, distance);
   plane->type = 1;
   parseObjProps(buffer, plane);
   plane->constructBB();
   plane->applyTransforms();
   
   objects.push_back(plane);
}

void PovParser::parseTriangle(stringstream& buffer) {
   Eigen::Vector3f pt1, pt2, pt3;
   Triangle* triangle;
   
   locateOpenBrace(buffer, "Triangle");
   pt1 = parseEVect3(buffer);
   locateComma(buffer, "Triangle");
   pt2 = parseEVect3(buffer);
   locateComma(buffer, "Triangle");
   pt3 = parseEVect3(buffer);
   
   triangle = new Triangle(pt1, pt2, pt3);
   triangle->type = 2;
   parseObjProps(buffer, triangle);
   triangle->constructBB();
   triangle->applyTransforms();
   
   objects.push_back(triangle);
}

void PovParser::parseBox(stringstream& buffer) {
   Eigen::Vector3f llbt, urft;
   Box* box;
   
   locateOpenBrace(buffer, "Box");
   llbt = parseEVect3(buffer);
   locateComma(buffer, "Box");
   urft = parseEVect3(buffer);
   
   box = new Box(llbt, urft);
   box->type = 3;
   parseObjProps(buffer, box);
   box->constructBB();
   box->applyTransforms();
   
   objects.push_back(box);
}

void PovParser::parseGW(stringstream& buffer) {
   string name;
   char curChar;
   Eigen::Vector3f ll, ur, dir, dirsubwave, subwavestats;
   float amp = 0.0f, wavel = 0.0f, speed = 0.0f, ypos = 0.0f, val;
   std::vector<Eigen::Vector3f> waves;
   waves.clear();
   
   GerstnerWave *gerstnerWave;
   locateOpenBrace(buffer, "GW");
   while ((curChar = buffer.get()) != '}') { 
      if (!buffer || curChar == '{') {
         perror("Error - PovRay - Camera - Bad Format (No Closed Brace)");
         exit(1);
      }
      
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         buffer.unget();
         buffer >> name;
         name.erase(remove(name.begin(), name.end(), '\n'), name.end());
         name.erase(remove(name.begin(), name.end(), '\r'), name.end());
         
         if (name == "lowerleft") {
            ll = parseEVect3(buffer);
         } else if (name == "upperright") {
            ur = parseEVect3(buffer);
         } else if (name == "direction") {
            dir = parseEVect3(buffer);
         } else if (name == "amplitude") {
            buffer >> amp;
         } else if (name == "wavelength") {
            buffer >> wavel;
         } else if (name == "speed") {
            buffer >> speed;
         } else if (name == "yposition") {
            buffer >> ypos;
         } else if (name == "wave") {
            locateOpenBrace(buffer, "GW_sub_wave");
            buffer >> subwavestats.x();
            buffer >> subwavestats.y();
            buffer >> subwavestats.z();
            waves.push_back(subwavestats);
            waves.push_back(parseEVect3(buffer));
            locateCloseBrace(buffer, "GW_sub_wave");
         } else if (name == "pigment" || name == "finish") {
            for (int i = 0; i < 7; i++) buffer.unget();
            break;
         } else {
            perror("Error - PovRay - GW - Bad Name");
            cout << "Name Given: " << name << endl;
            exit(1);
         }
      }
   }
   
   gerstnerWave = new GerstnerWave(amp, wavel, speed, dir, ll, ur, ypos);
   for (int i = 0; i < waves.size(); i+=2) {
      waves[i+1].normalize();
      gerstnerWave->addWave(waves[i].x(), waves[i].y(), waves[i].z(), waves[i+1]);
   }
   gerstnerWave->type = 5;
   
   parseObjProps(buffer, gerstnerWave);
   //gerstnerWave->constructBB();
   //gerstnerWave->applyTransforms();
   
   objects.push_back(gerstnerWave);
}

void PovParser::parseCone(stringstream& buffer) {
   Eigen::Vector3f endpt1, endpt2;
   float rad1, rad2;
   Cone* cone;
   
   locateOpenBrace(buffer, "Cone");
   endpt1 = parseEVect3(buffer);
   locateComma(buffer, "Cone");
   buffer >> rad1;
   locateComma(buffer, "Cone");
   endpt2 = parseEVect3(buffer);
   locateComma(buffer, "Cone");
   buffer >> rad2;
   
   cone = new Cone(endpt1, rad1, endpt2, rad2);
   cone->type = 4;
   parseObjProps(buffer, cone);
   cone->constructBB();
   cone->applyTransforms();
   
   objects.push_back(cone);
}

/***************SUB PARSING***************/
void PovParser::parseObjProps(stringstream& buffer, SceneObject* object) {
   string name;
   char curChar;
   
   while ((curChar = buffer.get()) != '}') {
      if (!buffer || curChar == '{') {
         perror("Error - PovRay - SceneObject - Bad Format (No Closed Brace)");
         exit(1);
      }
      
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         buffer.unget();
         buffer >> name;
         name.erase(remove(name.begin(), name.end(), '\n'), name.end());
         name.erase(remove(name.begin(), name.end(), '\r'), name.end());
         
         if (name == "pigment") {
            object->pigment = parsePigment(buffer);
         } else if (name == "finish") {
            parseFinish(buffer, object);
         } else if (name == "translate") {
            object->translateVector = parseEVect3(buffer);
         } else if (name == "rotate") {
            object->rotateVector = parseEVect3(buffer);
         } else if (name == "scale") {
            object->scaleVector = parseEVect3(buffer);
         } else { 
            perror("Error - PovRay - SceneObject - Bad Name");
            cout << "Name Given: " << name << endl;
            exit(1);
         }
      }
   }
}

Eigen::Vector4f PovParser::parsePigment(stringstream& buffer) {
   char curChar;
   string name;
   Eigen::Vector4f pigment;
   
   locateOpenBrace(buffer, "Pigment");
   buffer >> name;
   if (name != "color") {
      perror("Error - PovRay - Pigment - Bad Format (Name)");
      exit(1);
   }
   buffer >> name;
   
   if (name == "rgb") {
      Eigen::Vector3f col = parseEVect3(buffer);
      pigment = Eigen::Vector4f(col[0], col[1], col[2], 0.0);
   } else if (name == "rgbf") {
      pigment = parseEVect4(buffer);
   } else {
      perror("Error - PovRay - Pigment - Bad Name");
      cout << "Name Given: " << name << endl;
      exit(1);
   }
   locateCloseBrace(buffer, "Pigment");
   
   return pigment;
}

void PovParser::parseFinish(stringstream& buffer, SceneObject* object) {
   string name;
   char curChar;
   float val;
   locateOpenBrace(buffer, "Finish");
   while ((curChar = buffer.get()) != '}') {
      if (!buffer || curChar == '{') {
         perror("Error - PovRay - Finish - Bad Format (No Closed Brace)");
         exit(1);
      }
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         buffer.unget();
         buffer >> name;
         name.erase(remove(name.begin(), name.end(), '\n'), name.end());
         name.erase(remove(name.begin(), name.end(), '\r'), name.end());
         //cout << "do something cout fuck" << endl;
         buffer >> val;
         
         if (name == "ambient") object->ambient = val;
         else if (name == "diffuse") object->diffuse = val;
         else if (name == "specular") object->specular = val;
         else if (name == "roughness") object->roughness = val;
         else if (name == "reflection") object->reflection = val;
         else if (name == "refraction") object->refraction = val;
         else if (name == "ior") object->indexRefraction = val;
         else if (name == "preflect") object->photonReflectance = val;
         else if (name == "prefract") object->photonRefractance = val;
         else if (name == "dropoff") object->dropoff = val;
         else {
            perror("Error - PovRay - Finish - Bad Name");
            cout << "Name Given: " << name << endl;
            exit(1);
         }
      }
   }
}

/***************HELPERS***************/
Eigen::Vector3f PovParser::parseEVect3(stringstream& buffer) {
   char curChar;
   float v1, v2, v3;
   Eigen::Vector3f vect;
   
   locateOpenABrace(buffer, "Vector3Parse");
   buffer >> v1;
   locateComma(buffer, "Vector3Parse");
   buffer >> v2;
   locateComma(buffer, "Vector3Parse");
   buffer >> v3;
   locateCloseABrace(buffer, "Vector3Parse");
   
   return Eigen::Vector3f(v1, v2, v3);
}

Eigen::Vector4f PovParser::parseEVect4(stringstream& buffer) {
   char curChar;
   float v1, v2, v3, v4;
   Eigen::Vector4f vect;
   
   locateOpenABrace(buffer, "Vector4Parse");
   buffer >> v1;
   locateComma(buffer, "Vector4Parse");
   buffer >> v2;
   locateComma(buffer, "Vector4Parse");
   buffer >> v3;
   locateComma(buffer, "Vector4Parse");
   buffer >> v4;
   locateCloseABrace(buffer, "Vector4Parse");
   
   return Eigen::Vector4f(v1, v2, v3, v4);
}

void PovParser::locateOpenBrace(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != '{') {
      if (!buffer || curChar != ' ' && curChar != '\n' && curChar != '\r') {
         perror("Error - PovRay - Bad Format (No Open Brace)");
         cout << "Error on " << type << endl;
         exit(1);
      }
   }
}

void PovParser::locateCloseBrace(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != '}') { 
      if (!buffer || curChar == '{') {
         perror("Error - PovRay - Bad Format (No Closed Brace)");
         cout << "Error on " << type << endl;
         exit(1);
      }
   }
}

void PovParser::locateComma(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != ',') {
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         perror("Error - PovRay - No comma");
         cout << "Error on " << type << endl;
         exit(1);
      }
   }
}

void PovParser::locateOpenABrace(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != '<') {
      if (curChar != ' ' && curChar != '\n' && curChar != '\r') {
         perror("Error - PovRay - Bad Format (No Open Brace)");
         cout << "Error on " << type << endl;
         exit(1);
      }
   }
}

void PovParser::locateCloseABrace(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != '>') {
      if (curChar != ' ') {
         perror("Error - PovRay - Bad Format (No Closed Brace)");
         cout << "Error on " << type << endl;
         exit(1);
      }
   }
}

void PovParser::printObjects() {
   Eigen::Vector3f v;
   Eigen::Vector4f v4;
   Eigen::Matrix4f transform;
   cout << "Camera:" << endl;
   v = camera->getPosition();
   cout << "   Position: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getUp();
   cout << "   Up: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getRight();
   cout << "   Right: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getLookAt();
   cout << "   LookAt: " << v[0] << " " << v[1] << " " << v[2] << endl;
   for (int i = 0; i < lights.size(); i++) {
      cout << "Light " << i << ":" << endl;
      v = lights[i]->getPosition();
      cout << "   Position: " << v[0] << " " << v[1] << " " << v[2] << endl;
      v = lights[i]->getColor();
      cout << "   Color: " << v[0] << " " << v[1] << " " << v[2] << endl;
   }
   for (int i = 0; i < objects.size(); i++) {
      cout << "Object " << i << ":" << endl;
      v4 = objects[i]->pigment;
      cout << "   Pigment: " << v4[0] << " " << v4[1] << " " << v4[2] << " " << v4[3] << endl;
      v = objects[i]->translateVector;
      cout << "   Translate: " << v[0] << " " << v[1] << " " << v[2] << endl;
      v = objects[i]->rotateVector;
      cout << "   Rotate: " << v[0] << " " << v[1] << " " << v[2] << endl;
      v = objects[i]->scaleVector;
      cout << "   Scale: " << v[0] << " " << v[1] << " " << v[2] << endl;
      transform = objects[i]->transform;
      cout << "   Transform Matrix:" << endl << transform << endl;
      cout << "   Ambient: " << objects[i]->ambient << endl;
      cout << "   Diffuse: " << objects[i]->diffuse << endl;
      cout << "   Specular: " << objects[i]->specular << endl;
      cout << "   Roughness: " << objects[i]->roughness << endl;
      cout << "   Reflection: " << objects[i]->reflection << endl;
      cout << "   Refraction: " << objects[i]->refraction << endl;
      cout << "   IndexRefraction: " << objects[i]->indexRefraction << endl;
      if (objects[i]->type == 0) {
         Sphere* s = static_cast<Sphere*>(objects[i]);
         v = s->position;
         cout << "   Position: " << v[0] << " " << v[1] << " " << v[2] << endl;
         cout << "   Radius: " << s->radius << endl;
      } else if (objects[i]->type == 1) {
         Plane* p = static_cast<Plane*>(objects[i]);
         v = p->normal;
         cout << "   Normal: " << v[0] << " " << v[1] << " " << v[2] << endl;
         cout << "   Distance: " << p->distance << endl;
      } else if (objects[i]->type == 2) {
         Triangle* t = static_cast<Triangle*>(objects[i]);
         cout << "   Point 1: " << t->a.x() << " " << t->a.y() << " " << t->a.z() << " " << endl;
         cout << "   Point 2: " << t->b.x() << " " << t->b.y() << " " << t->b.z() << " " << endl;
         cout << "   Point 3: " << t->c.x() << " " << t->c.y() << " " << t->c.z() << " " << endl;
      }
   }
}
