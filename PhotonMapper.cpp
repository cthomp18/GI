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
   printf("type %d\n", objects[0]->type);
}

void PhotonMapper::buildGlobalMap() {
   float u1, u2, phi, r;
   //int index;
   int depth;
   int count = 0;
   Photon *p;
   Light *light;
   float shF[9];
   int shI[3];
   glm::vec3 ray, intersectPt, normal, reflectRay, tempIntensity, tempIPt;
   float n1 = AIR_REFRACT_INDEX, n2, randTracker;
   RayTracer* raytrace = new RayTracer(&lights, &objects);
   
   //printf("PM TYPE %d\n", objects[0]->type);
   //printf("RT TYPE2 %d\n", raytrace->objects[0]->type);
   Collision* col;
   SceneObject* obj;
      cout << lights.size() << endl;
   for (uint l = 0; l < lights.size(); l++) {
      light = lights[l];
      //printf("uhhhhh222 %f %f %f\n", light->getPosition().x, light->getPosition().y, light->getPosition().z);
      for (int i = 0; i < GLOBALPHOTONS; i++) {
         //printf("a\n");
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
         //printf("PM TYPE2 %d\n", objects[0]->type);
         //printf("RT TYPE2 %d\n", raytrace->objects[0]->type);
         //printf("1\n");
         //printf("uhhhhh111 %f %f %f\n", light->getPosition().x, light->getPosition().y, light->getPosition().z);
         col = raytrace->trace(light->getPosition(), ray, -1, shI, shF);
         //printf("hello2? %f %f %f\n", shF[6], shF[7], shF[8]);
         //printf("cmonbruh1\n");
         //printf("pig: %f", col->object->pigment[0]);//, obj->pigment[1], obj->pigment[2]);
         //printf("done\n");
         //printf("2\n");
         //printf("b\n");
         if (col->time >= TOLERANCE) {
            //printf("blah\n");
            obj = col->object;
            //cout << col->objectIndex << endl;
            intersectPt = light->getPosition() + (col->time * ray);
            
            //Direct Photons
            //printf("blahh\n");
            p = new Photon(intersectPt, ray, light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS), 0); 
            //printf("seriously??\n");
            if (obj == NULL) {
               //printf("yahh...\n");
            } else {
               //printf("fuck\n");
               //obj->pigment = glm::vec4(0.0, 0.0, 0.0, 0.0);
               //printf("hello\n");
               //if (obj->pigment[0] == NULL) printf("wut\n");
               //printf("pig: %f", obj->pigment[0]);//, obj->pigment[1], obj->pigment[2]);
               //printf("dif: %f\n", obj->diffuse);
               //printf("int: %f\n", p->intensity[0], p->intensity[1], p->intensity[2]);
            }
            if (p == NULL) {
               //printf("que?\n");
            }
            p->intensity[0] *= obj->pigment[0] * obj->diffuse;
            //printf("??1\n");
            p->intensity[1] *= obj->pigment[1] * obj->diffuse;
            //printf("??2\n");
            p->intensity[2] *= obj->pigment[2] * obj->diffuse;
            //printf("???\n");
            globalPhotons.push_back(p);
            //printf("blahhh\n");
            tempIntensity = p->intensity;
            n2 = obj->indexRefraction;
            //index = col->objectIndex;
            
            //Shadow Photons
            tempIPt = intersectPt;
            //printf("blahhhh\n");
            if (obj->type == 0) {
               while (col->time >= TOLERANCE) {
                  delete col;
                  //printf("3\n");
                  col = raytrace->trace(tempIPt, ray, -1, shI, shF);
                  //printf("4\n");
                  if (col->time >= TOLERANCE) {
                     tempIPt = tempIPt + (col->time * ray);
                     p = new Photon(tempIPt, ray, light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS), 2);
                     //printf("cmonbruh2\n");
                     p->intensity[0] *= col->object->pigment[0] * col->object->ambient;
                     p->intensity[1] *= col->object->pigment[1] * col->object->ambient;
                     p->intensity[2] *= col->object->pigment[2] * col->object->ambient;
                     //printf("done\n");
                     globalPhotons.push_back(p);
                  }
               }
            }
            depth = 0;
            //printf("uh1\n");
            //Reflected Photons
            while ((randTracker = (float)(rand()) / (float)(RAND_MAX)) < obj->photonReflectance + obj->photonRefractance) {
               //printf("uh2\n");               
               if (randTracker < obj->photonReflectance) { //Reflect
                  normal = obj->getNormal(obj, intersectPt, shF);
                  ray = raytrace->findReflect(ray, normal, obj);
                  delete col;
                  //printf("5\n");
                  col = raytrace->trace(intersectPt, ray, -1, shI, shF);
                  //printf("6\n");
                  
                  if (col->time >= TOLERANCE) {
                     obj = col->object;
                     intersectPt = intersectPt + (col->time * ray);
                     
                     p = new Photon(intersectPt, ray, tempIntensity, 1);
                     //printf("cmonbruh3\n");
                     p->intensity[0] *= obj->pigment[0] * obj->diffuse;
                     p->intensity[1] *= obj->pigment[1] * obj->diffuse;
                     p->intensity[2] *= obj->pigment[2] * obj->diffuse;
                     //printf("done\n");
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
                  normal = obj->getNormal(obj, intersectPt, shF);
                  ray = raytrace->findRefract(ray, normal, obj, n1, &n2, &randFloat, &randFloat);
                  delete col;
                  //printf("7\n");
                  col = raytrace->trace(intersectPt, ray, -1, shI, shF);
                  //printf("8\n");
                  //intersectPt = intersectPt + (col->time * ray);
                  /*obj = objects[col->objectIndex];
                  normal = obj->getNormal(obj, intersectPt, 2.0f);
                  ray = raytrace->findReflect(ray, -normal, obj, n2, n1, 1);
                  col = raytrace->trace(intersectPt, ray, -1);*/
                  
                  if(col->time >= TOLERANCE) {
                     obj = col->object;
                     intersectPt = intersectPt + (col->time * ray);
                     
                     p = new Photon(intersectPt, ray, tempIntensity, 1);
                     //printf("cmonbruh4\n");
                     p->intensity[0] *= obj->pigment[0] * obj->diffuse;
                     p->intensity[1] *= obj->pigment[1] * obj->diffuse;
                     p->intensity[2] *= obj->pigment[2] * obj->diffuse;
                     //printf("done\n");
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
                  //printf("uh3\n");
                  break;
               }
               //printf("uh4\n");
            }
         } else {
            //std::cout << "MISS" << std::endl;
            //std::cout << ray << std::endl;
            count++;
         }
         //printf("c\n");
         delete col;
         //printf("d\n");
      }
   }
   //cout << "count:" << count << endl;
   delete raytrace;
}

void PhotonMapper::buildCausticMap() {
   Photon *p;
   Light *light;
   float shF[9];
   int shI[3];
   glm::vec3 ray, intersectPt, reflectRay, tempIntensity, pos, lpos, normal;
   float n1 = AIR_REFRACT_INDEX, n2, randTracker;
   int missCount = 0;//, depth = 0;//, index;
   float minX, minY, minZ, maxX, maxY, maxZ;
   SceneObject* obj, *tempobj;
   Collision* col;
   RayTracer* raytrace = new RayTracer(&lights, &objects);
   cout << "Caustics: " << causticPhotons.size() << endl;
   for (uint l = 0; l < lights.size(); l++) {
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
               
               col = raytrace->trace(lpos, ray, -1, shI, shF);

               if (col->time >= TOLERANCE && fabs(col->object->refraction - 1.0f) < TOLERANCE) {
                  intersectPt = lpos + (col->time * ray);
                  tempIntensity = light->getColor() / (float)(GLOBALPHOTONS + CAUSTICPHOTONS);
                  obj = col->object;
                  n2 = obj->indexRefraction;
                  
                  //Get indirect photons
                  tempobj = obj;
                  while ((randTracker = (float)(rand()) / (float)(RAND_MAX)) < tempobj->photonRefractance) {
                     float randFloat;
                     normal = tempobj->getNormal(tempobj, intersectPt, shF);
                     ray = raytrace->findRefract(ray, normal, tempobj, n1, &n2, &randFloat, &randFloat);
                     delete col;
                     col = raytrace->trace(intersectPt, ray, -1, shI, shF);
                     //if (col->objectIndex != m) cout << "fucking wut " << n1 << " " << n2 << endl;
                     /*intersectPt = intersectPt + (col->time * ray);
                     tempobj = objects[col->objectIndex];
                     normal = tempobj->getNormal(tempobj, intersectPt, 2.0f);
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
               delete col;
            }
            std::cout << "i: " << i << " z: " << z << std::endl;
            cout << "Caustics: " << causticPhotons.size() << endl;
            std::cout << "Miss Count: " << missCount << std::endl;
         //}
      //}
   }
   delete raytrace;
}
