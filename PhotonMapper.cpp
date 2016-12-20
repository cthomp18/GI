/*
   Cody Thompson
   Photon Mapping
*/

#include "PhotonMapper.h"

using namespace std;

PhotonMapper::PhotonMapper() {
   globalPhotons.clear();
   causticPhotons.clear();
}

PhotonMapper::~PhotonMapper() { }

PhotonMapper::PhotonMapper(std::vector<Light*> l, std::vector<SceneObject*> o) {
   lights = l;
   objects = o;
}

void PhotonMapper::buildGlobalMap() {
   float nP = (float)GLOBALPHOTONS, u1, u2, phi, r;
   int index;
   int depth;
   int count = 0;
   Photon *p;
   Light *light;
   glm::vec3 ray, intersectPt, normal, reflectRay, tempIntensity, tempIPt;
   float n1 = AIR_REFRACT_INDEX, n2, randTracker, reflect, refract, angle, t;
   RayTracer* raytrace = new RayTracer(lights, objects);
   Collision* col;
   SceneObject* obj;
      //cout << lights.size() << endl;
   for (int l = 0; l < lights.size(); l++) {
      light = lights[l];
      for (int i = 0; i < GLOBALPHOTONS; i++) {
         if (i == 0) cout << "0%" << endl;
         else if (i == int(GLOBALPHOTONS*.25)) cout << "25%" << endl;
         else if (i == int(GLOBALPHOTONS*.5)) cout << "50%" << endl;
         else if (i == int(GLOBALPHOTONS*.75)) cout << "75%" << endl;
         n1 = AIR_REFRACT_INDEX;
         //ray[0] = (((float)(rand()) / (float)(RAND_MAX)) * 2.0) - 1.0;
         //ray[1] = (((float)(rand()) / (float)(RAND_MAX)) * 2.0) - 1.0;
         //ray[2] = (((float)(rand()) / (float)(RAND_MAX)) * 2.0) - 1.0;
         u1 = (((float)(rand()) / (float)(RAND_MAX)) * 2.0) - 1.0;
         u2 = (((float)(rand()) / (float)(RAND_MAX)) * 2.0) - 1.0;
         r = sqrt(1.0f - u1 * u1);
         phi = 2 * M_PI * u2;
         ray = glm::vec3(cos(phi) * r, sin(phi) * r, u1);
         ray = glm::normalize(ray);
         
         col = raytrace->trace(light->getPosition(), ray, -1);
         
         if (col->time >= TOLERANCE) {
            
            obj = col->object;
            //cout << col->objectIndex << endl;
            intersectPt = light->getPosition() + (col->time * ray);
            
            //Direct Photons
            p = new Photon(intersectPt, ray, light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS), 0);            
            p->intensity[0] *= obj->pigment[0] * obj->diffuse;
            p->intensity[1] *= obj->pigment[1] * obj->diffuse;
            p->intensity[2] *= obj->pigment[2] * obj->diffuse;
            globalPhotons.push_back(p);
            
            tempIntensity = p->intensity;
            n2 = obj->indexRefraction;
            //index = col->objectIndex;
            
            //Shadow Photons
            tempIPt = intersectPt;
            if (obj->type == 0) {
               while (col->time >= TOLERANCE) {
                  col = raytrace->trace(tempIPt, ray, -1);
                  if (col->time >= TOLERANCE) {
                     tempIPt = tempIPt + (col->time * ray);
                     p = new Photon(tempIPt, ray, light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS), 2);
                     p->intensity[0] *= col->object->pigment[0] * col->object->ambient;
                     p->intensity[1] *= col->object->pigment[1] * col->object->ambient;
                     p->intensity[2] *= col->object->pigment[2] * col->object->ambient;
                     globalPhotons.push_back(p);
                  }
               }
            }
            depth = 0;
            //Reflected Photons
            while ((randTracker = (float)(rand()) / (float)(RAND_MAX)) < obj->photonReflectance + obj->photonRefractance) {               
               if (randTracker < obj->photonReflectance) { //Reflect
                  normal = obj->getNormal(intersectPt, 2.0f);
                  ray = raytrace->findReflect(ray, normal, obj);
                  col = raytrace->trace(intersectPt, ray, -1);
                  
                  if (col->time >= TOLERANCE) {
                     obj = col->object;
                     intersectPt = intersectPt + (col->time * ray);
                     
                     p = new Photon(intersectPt, ray, tempIntensity, 1);
                     p->intensity[0] *= obj->pigment[0] * obj->diffuse;
                     p->intensity[1] *= obj->pigment[1] * obj->diffuse;
                     p->intensity[2] *= obj->pigment[2] * obj->diffuse;
                     globalPhotons.push_back(p);
                     
                     tempIntensity = p->intensity;
                     n2 = obj->indexRefraction;
                     //index = col->objectIndex;
                  } else {
                     break;
                  }
                  depth++;
               } else if (randTracker < obj->photonRefractance) { //Refract
                  float randFloat;
                  normal = obj->getNormal(intersectPt, 2.0f);
                  ray = raytrace->findRefract(ray, normal, obj, n1, &n2, &randFloat, &randFloat);
                  col = raytrace->trace(intersectPt, ray, -1);
                  //intersectPt = intersectPt + (col->time * ray);
                  /*obj = objects[col->objectIndex];
                  normal = obj->getNormal(intersectPt, 2.0f);
                  ray = raytrace->findReflect(ray, -normal, obj, n2, n1, 1);
                  col = raytrace->trace(intersectPt, ray, -1);*/
                  
                  if(col->time >= TOLERANCE) {
                     obj = col->object;
                     intersectPt = intersectPt + (col->time * ray);
                     
                     p = new Photon(intersectPt, ray, tempIntensity, 1);
                     p->intensity[0] *= obj->pigment[0] * obj->diffuse;
                     p->intensity[1] *= obj->pigment[1] * obj->diffuse;
                     p->intensity[2] *= obj->pigment[2] * obj->diffuse;
                     //i--;
                     
                     tempIntensity = p->intensity;
                     //n2 = obj->indexRefraction;
                     n1 = n2;
                     //index = col->objectIndex;
                     
                     /*if (depth <= 1) {
                        i--;
                        continue;
                     } else {*/
                        globalPhotons.push_back(p);
                     //}
                  } else {
                     break;
                  }
                  depth++;
               } else {
                  break;
               }
            }
         } else {
            //std::cout << "MISS" << std::endl;
            //std::cout << ray << std::endl;
            count++;
         }
      }
   }
   cout << "count:" << count << endl;
}

void PhotonMapper::buildCausticMap() {
   float nP = (float)GLOBALPHOTONS;
   Photon *p;
   Light *light;
   glm::vec3 ray, intersectPt, reflectRay, tempIntensity, pos, lpos, normal;
   float n1 = AIR_REFRACT_INDEX, n2, randTracker, rad;
   int depth = 0, missCount = 0, index;
   float minX, minY, minZ, maxX, maxY, maxZ;
   SceneObject* obj, *tempobj;
   Collision* col;
   RayTracer* raytrace = new RayTracer(lights, objects);
   cout << "Caustics: " << causticPhotons.size() << endl;
   for (int l = 0; l < lights.size(); l++) {
      light = lights[l];
      //for (int m = 0; m < objects.size(); m++) {
         //obj = objects[m];
         //if (obj->photonRefractance > TOLERANCE) {
            //if (obj->type == 0) {
               //cout << "making sure" << endl;
               //Sphere* s = static_cast<Sphere*>(obj);
               //pos = s->position;
               //rad = s->radius;
               lpos = light->getPosition();
               //minX = (pos[0] - rad) - lpos[0]; maxX = (pos[0] + rad) - lpos[0];
               //minY = (pos[1] - rad) - lpos[1]; maxY = (pos[1] + rad) - lpos[1];
               //minZ = (pos[2] - rad) - lpos[2]; maxZ = (pos[2] + rad) - lpos[2];
               minX = -3.5f - lpos[0]; maxX = 3.5f - lpos[0];
               minY = -1.0f - lpos[1]; maxY = -1.0f - lpos[1];
               minZ = -13.0f - lpos[2]; maxZ = 1.5f - lpos[2];
           // }
            //cout << "Min: " << minX << " " << minY << " " << minZ << endl;
            //cout << "Max: " << maxX << " " << maxY << " " << maxZ << endl;
            missCount = 0;
            int i = 0, z = 0;
            for ( ; i < CAUSTICPHOTONS && missCount < 1000 * CAUSTICPHOTONS; i++) {
               if (i == 0) cout << "0%" << endl;
               else if (i == int(CAUSTICPHOTONS*.25)) cout << "25%" << endl;
               else if (i == int(CAUSTICPHOTONS*.5)) cout << "50%" << endl;
               else if (i == int(CAUSTICPHOTONS*.75)) cout << "75%" << endl;
               n1 = AIR_REFRACT_INDEX;
               ray[0] = minX + (((float)(rand()) / (float)(RAND_MAX)) * (maxX - minX));
               ray[1] = minY + (((float)(rand()) / (float)(RAND_MAX)) * (maxY - minY));
               ray[2] = minZ + (((float)(rand()) / (float)(RAND_MAX)) * (maxZ - minZ));
               ray = glm::normalize(ray);
               col = raytrace->trace(lpos, ray, -1);

               if (col->time >= TOLERANCE && fabs(col->object->refraction - 1.0f) < TOLERANCE) {
                  intersectPt = lpos + (col->time * ray);
                  tempIntensity = light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS);
                  obj = col->object;
                  n2 = obj->indexRefraction;
                  
                  //Get indirect photons
                  tempobj = obj;
                  while ((randTracker = (float)(rand()) / (float)(RAND_MAX)) < tempobj->photonRefractance) {
                     float randFloat;
                     normal = tempobj->getNormal(intersectPt, 2.0f);
                     ray = raytrace->findRefract(ray, normal, tempobj, n1, &n2, &randFloat, &randFloat);
                     col = raytrace->trace(intersectPt, ray, -1);
                     //if (col->objectIndex != m) cout << "fucking wut " << n1 << " " << n2 << endl;
                     /*intersectPt = intersectPt + (col->time * ray);
                     tempobj = objects[col->objectIndex];
                     normal = tempobj->getNormal(intersectPt, 2.0f);
                     ray = raytrace->findReflect(ray, -normal, tempobj, n2, n1, 1);
                     col = raytrace->trace(intersectPt, ray, -1);*/
                     
                     if(col->time >= TOLERANCE) {
                        tempobj = col->object;
                        intersectPt = intersectPt + (col->time * ray);
                        
                        p = new Photon(intersectPt, ray, tempIntensity, 1);
                        //p->intensity[0] *= obj->pigment[0] * obj->diffuse;
                        //p->intensity[1] *= obj->pigment[1] * obj->diffuse;
                        //p->intensity[2] *= obj->pigment[2] * obj->diffuse;
                        n1 = n2;
                        causticPhotons.push_back(p);
                        
                        //tempIntensity = p->intensity;
                        //n2 = tempobj->indexRefraction;
                        //index = col->objectIndex;
                     } else {
                        //cout << "the fuck " << col->time << endl;
                        break;
                     }
                  }
               } else {
                  //cout << "MISS" << endl;
                  //cout << ray << endl;
                  i--;
                  missCount++;
               }
            }
            std::cout << "i: " << i << " z: " << z << std::endl;
            cout << "Caustics: " << causticPhotons.size() << endl;
            std::cout << "Miss Count: " << missCount << std::endl;
         //}
      //}
   }
}
