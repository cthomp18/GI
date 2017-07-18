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
         parseTriangle(buffer, 0);
      } else if (name == "triangleN") {
         parseTriangle(buffer, 1);
      } else if (name == "cone") {
         parseCone(buffer);
      } else if (name == "box") {
         parseBox(buffer);
      } else if (name == "gerstner_wave") {
         parseGW(buffer);
      } else if (name == "object") {
         parseObj(buffer);
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
   glm::vec3 loc, up, right, lookat;
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
   glm::vec3 lpos, lcol;
   
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
   glm::vec3 loc;
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
   glm::vec3 normal;
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

void PovParser::parseTriangle(stringstream& buffer, int norms) {
   glm::vec3 pt1, pt2, pt3;
   glm::vec3 n1, n2, n3;
   Triangle* triangle;
   
   locateOpenBrace(buffer, "Triangle");
   pt1 = parseEVect3(buffer);
   locateComma(buffer, "Triangle");
   pt2 = parseEVect3(buffer);
   locateComma(buffer, "Triangle");
   pt3 = parseEVect3(buffer);
   
   triangle = new Triangle(pt1, pt2, pt3);
   
   if (norms) {
      locateOpenBrace(buffer, "Triangle");
      n1 = parseEVect3(buffer);
      locateComma(buffer, "Triangle");
      n2 = parseEVect3(buffer);
      locateComma(buffer, "Triangle");
      n3 = parseEVect3(buffer);
      
      triangle->smooth = true;
      triangle->aNor = n1;
      triangle->bNor = n2;
      triangle->cNor = n3;
   }
   
   triangle->type = 2;
   parseObjProps(buffer, triangle);
   triangle->constructBB();
   triangle->applyTransforms();
   
   objects.push_back(triangle);
}

void PovParser::parseBox(stringstream& buffer) {
   glm::vec3 llbt, urft;
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
   glm::vec3 ll, ur, dir, dirsubwave, subwavestats;
   float amp = 0.0f, wavel = 0.0f, speed = 0.0f, ypos = 0.0f;
   std::vector<glm::vec3> waves;
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
            buffer >> subwavestats.x;
            buffer >> subwavestats.y;
            buffer >> subwavestats.z;
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
   for (uint i = 0; i < waves.size(); i+=2) {
      waves[i+1] = glm::normalize(waves[i+1]);
      gerstnerWave->addWave(waves[i].x, waves[i].y, waves[i].z, waves[i+1]);
   }
   gerstnerWave->type = 5;
   
   parseObjProps(buffer, gerstnerWave);
   //gerstnerWave->constructBB();
   //gerstnerWave->applyTransforms();
   
   objects.push_back(gerstnerWave);
}

void PovParser::parseObj(stringstream& buffer) {
   string objFileName;
   
   locateOpenBrace(buffer, "Object");
   buffer >> objFileName;
   ObjToPov(objFileName);
   
   locateCloseBrace(buffer, "Object");
}

void PovParser::parseCone(stringstream& buffer) {
   glm::vec3 endpt1, endpt2;
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
            object->transformed = true;
         } else if (name == "rotate") {
            object->rotateVector = parseEVect3(buffer);
            object->transformed = true;
         } else if (name == "scale") {
            object->scaleVector = parseEVect3(buffer);
            object->transformed = true;
         } else { 
            perror("Error - PovRay - SceneObject - Bad Name");
            cout << "Name Given: " << name << endl;
            exit(1);
         }
      }
   }
}

glm::vec4 PovParser::parsePigment(stringstream& buffer) {
   string name;
   glm::vec4 pigment;
   
   locateOpenBrace(buffer, "Pigment");
   buffer >> name;
   if (name != "color") {
      perror("Error - PovRay - Pigment - Bad Format (Name)");
      exit(1);
   }
   buffer >> name;
   
   if (name == "rgb") {
      glm::vec3 col = parseEVect3(buffer);
      pigment = glm::vec4(col[0], col[1], col[2], 0.0);
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
glm::vec3 PovParser::parseEVect3(stringstream& buffer) {
   float v1, v2, v3;
   glm::vec3 vect;
   
   locateOpenABrace(buffer, "Vector3Parse");
   buffer >> v1;
   locateComma(buffer, "Vector3Parse");
   buffer >> v2;
   locateComma(buffer, "Vector3Parse");
   buffer >> v3;
   locateCloseABrace(buffer, "Vector3Parse");
   
   return glm::vec3(v1, v2, v3);
}

glm::vec4 PovParser::parseEVect4(stringstream& buffer) {
   float v1, v2, v3, v4;
   glm::vec4 vect;
   
   locateOpenABrace(buffer, "Vector4Parse");
   buffer >> v1;
   locateComma(buffer, "Vector4Parse");
   buffer >> v2;
   locateComma(buffer, "Vector4Parse");
   buffer >> v3;
   locateComma(buffer, "Vector4Parse");
   buffer >> v4;
   locateCloseABrace(buffer, "Vector4Parse");
   
   return glm::vec4(v1, v2, v3, v4);
}

void PovParser::locateOpenBrace(stringstream& buffer, string type) {
   char curChar;
   while ((curChar = buffer.get()) != '{') {
      if (!buffer || (curChar != ' ' && curChar != '\n' && curChar != '\r')) {
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
   glm::vec3 v;
   glm::vec4 v4;
   glm::mat4 transform;
   cout << "Camera:" << endl;
   v = camera->getPosition();
   cout << "   Position: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getUp();
   cout << "   Up: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getRight();
   cout << "   Right: " << v[0] << " " << v[1] << " " << v[2] << endl;
   v = camera->getLookAt();
   cout << "   LookAt: " << v[0] << " " << v[1] << " " << v[2] << endl;
   for (uint i = 0; i < lights.size(); i++) {
      cout << "Light " << i << ":" << endl;
      v = lights[i]->getPosition();
      cout << "   Position: " << v[0] << " " << v[1] << " " << v[2] << endl;
      v = lights[i]->getColor();
      cout << "   Color: " << v[0] << " " << v[1] << " " << v[2] << endl;
   }
   for (uint i = 0; i < objects.size(); i++) {
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
      //cout << "   Transform Matrix:" << endl << glm::to_string(transform) << endl;
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
         cout << "   Point 1: " << t->a.x << " " << t->a.y << " " << t->a.z << " " << endl;
         cout << "   Point 2: " << t->b.x << " " << t->b.y << " " << t->b.z << " " << endl;
         cout << "   Point 3: " << t->c.x << " " << t->c.y << " " << t->c.z << " " << endl;
      }
   }
}

/* Very simple OBJ to Povray file converter (insert without extension)
   Requires an mtl, otherwise defaulted material to white full diffuse
   If there is an mtl file, it must be the same as the obj
   Yes, I know it's only an extra parameter. I don't care.
*/
void PovParser::ObjToPov(string filename) {
   ifstream file;
   filename += ".obj";
   const char *fn = filename.c_str();
   
   file.open(fn);
   if (!file) {
      perror("Bad File");
      exit(1);
   }

   stringstream buffer;
   buffer.clear();
   //buffer << file.rdbuf();
   
   ofstream meshFile;
   
   std::vector<glm::vec3> verts;
   std::vector<glm::vec3> norms;
   float t1, t2, t3;
   int i, j, k;
   string action, temp, line;
   Triangle *objTri;
   
   float shrink = 20.0f;
   bool calc = false;
   float minx = FLT_MAX, miny = FLT_MAX, minz = FLT_MAX;
   float maxx = FLT_MIN, maxy = FLT_MIN, maxz = FLT_MIN;
   float rangex = 0, rangey = 0, rangez = 0;
   
   glm::vec3 trans = glm::vec3(0.0f, 0.0f, 0.0f);
   
   while (!file.eof()) {
      std::getline(file, line);
      buffer.str(line);
      buffer >> action;
      if (!action.compare("v")) {
         buffer >> t1;
         buffer >> t2;
         buffer >> t3;
         
         if (t1 < minx) minx = t1;
         else if (t1 > maxx) maxx = t1;
         if (t2 < miny) miny = t2;
         else if (t2 > maxy) maxy = t2;
         if (t3 < minz) minz = t3;
         else if (t3 > maxz) maxz = t3;
         
         verts.push_back(glm::vec3(t1, t2, t3));
         //cout << t1 << " " << t2 << " " << t3 << endl;
      } else if (!action.compare("vn")) {
         buffer >> t1;
         buffer >> t2;
         buffer >> t3;
         norms.push_back(glm::vec3(t1, t2, t3));
         //cout << t1 << " " << t2 << " " << t3 << endl;
      } else if (!action.compare("f")) {
         if (!calc) {
            rangex = maxx - minx;
            rangey = maxy - miny;
            rangez = maxz - minz;
            
            if (rangex > rangey && rangex > rangez) shrink = rangex / shrink;
            else if (rangey > rangex && rangey > rangez) shrink = rangey / shrink;
            else shrink = rangez / shrink;
            
            minx = miny = minz = FLT_MAX;
            maxx = maxy = maxz = FLT_MIN;
            for (uint i = 0; i < verts.size(); i++) {
               verts[i].x /= shrink;
               verts[i].y /= shrink;
               verts[i].z /= shrink;
               if (verts[i].x < minx) minx = verts[i].x;
               else if (verts[i].x > maxx) maxx = verts[i].x;
               if (verts[i].y < miny) miny = verts[i].y;
               else if (verts[i].y > maxy) maxy = verts[i].y;
               if (verts[i].z < minz) minz = verts[i].z;
               else if (verts[i].z > maxz) maxz = verts[i].z;
            }
            
            trans.x = -((maxx + minx) / 2.0f);
            trans.y = -((maxy + miny) / 2.0f);
            trans.z = -((maxz + minz) / 2.0f);
            
            for (uint i = 0; i < verts.size(); i++) {
               verts[i].x = verts[i].x + trans.x;
               verts[i].y = verts[i].y + trans.y;
               verts[i].z = verts[i].z + trans.z;
            }
            
            calc = true;
            
            cout << "Mins: " << minx << " " << miny << " " << minz << endl;
            cout << "Maxs: " << maxx << " " << maxy << " " << maxz << endl;
            cout << "Ranges: " << rangex << " " << rangey << " " << rangez << endl;
            cout << "Trans: " << trans.x << " " << trans.y << " " << trans.z << endl;
            cout << "Shrink: " << shrink << endl;
            
            
            
            /*minx = miny = minz = FLT_MAX;
            maxx = maxy = maxz = FLT_MIN;
            cout << "SIZE: " << verts.size() << endl;;
            cout << "Mins: " << minx << " " << miny << " " << minz << endl;
            cout << "Maxs: " << maxx << " " << maxy << " " << maxz << endl;
            for (int i = 0; i < verts.size(); i++) {
               //cout << " HELLO ??? " << endl;
               if (verts[i].x < minx) minx = verts[i].x;
               else if (verts[i].x > maxx) maxx = verts[i].x;
               if (verts[i].y < miny) miny = verts[i].y;
               else if (verts[i].y > maxy) maxy = verts[i].y;
               if (verts[i].z < minz) minz = verts[i].z;
               else if (verts[i].z > maxz) maxz = verts[i].z;
            }
            rangex = maxx - minx;
            rangey = maxy - miny;
            rangez = maxz - minz;
            
            trans.x = -((maxx + minx) / 2.0f);
            trans.y = -((maxy + miny) / 2.0f);
            trans.z = -((maxz + minz) / 2.0f);
            if (rangex > rangey && rangex > rangez) shrink = rangex / shrink;
            if (rangey > rangex && rangey > rangez) shrink = rangey / shrink;
            else shrink = rangez / shrink;
            
            cout << "Mins: " << minx << " " << miny << " " << minz << endl;
            cout << "Maxs: " << maxx << " " << maxy << " " << maxz << endl;
            cout << "Ranges: " << rangex << " " << rangey << " " << rangez << endl;
            cout << "Trans: " << trans.x << " " << trans.y << " " << trans.z << endl;
            cout << "Shrink: " << shrink << endl;*/
         }
         buffer >> i;
         buffer >> temp;
         buffer >> j;
         buffer >> temp;
         buffer >> k;
         buffer >> temp;
         //cout << i << " " << j << " " << k << endl;
         objTri = new Triangle(verts[i-1], verts[j-1], verts[k-1], true);
         objTri->aNor = norms[i-1];
         objTri->bNor = norms[j-1];
         objTri->cNor = norms[k-1];
         objTri->pigment = glm::vec4(1.0, 1.0, 1.0, 0.0);
         objTri->photonReflectance = 0.5;
         objTri->photonRefractance = 0.0;
         objTri->type = 2;
         objTri->constructBB();
         
         objects.push_back(objTri);
      }
   }
   file.close();
}
