/*
   Cody Thompson
   Photon Mapping
*/

#include <iostream>
#include "RayTracer.h"

using namespace std;

RayTracer::RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o) {
   lights = l;
   objects = o;
}

RayTracer::RayTracer(std::vector<Light*> l, std::vector<SceneObject*> o, std::vector<Photon*> gM, std::vector<Photon*> cM, KDTreeNode* gr, KDTreeNode* cr) {
   lights = l;
   objects = o;
   globalMap = gM;
   causticMap = cM;
   root = gr;
   rootC1 = cr;
}

RayTracer::RayTracer() { }
RayTracer::~RayTracer() { }

Collision* RayTracer::trace(Eigen::Vector3f start, Eigen::Vector3f ray, bool unit) {
   Collision* c = new Collision();   
   c->detectRayCollision(start, ray, objects, -1, unit);
   return c;
}

color_t RayTracer::calcRadiance(Eigen::Vector3f start, Eigen::Vector3f iPt, SceneObject* obj, bool unit, float scale, float n1, float dropoff, int depth) {
   int numGPhotons = globalMap.size();
   int numCPhotons = causticMap.size();
   float e = 2.71828;
   float alpha = 0.918;
   float beta = 1.953;
   
   int causts;
   float x, y, z, t, c, s, w, d;
   float sampleDistSqrd, newRadSqrd, scaleN;
   std::vector<Photon*> locateHeap;
   Eigen::Vector3f eRay = Eigen::Vector3f(0.0, 0.0, 1.0);
   Eigen::Matrix3f mat, matInv;
   
   color_t clr, absorbClr, reflectClr, refractClr;
   float dots1 = 0.0, dots2 = 0.0, temp, temp2, time, mainDist, mainT, dist, reflectance = 1.0f / obj->roughness, D, F, G, m, n2, sroot, R = 0.0f, R0 = 0.0f, innersqr = 1.0f, reflectScale, tempDO;
   Eigen::Vector3f colorD, colorS, colorA, color, normal, reflectRay, newStart, newIPt, crossP;
   Eigen::Vector4f tempNormal, tempStart, tempIPt;
   Eigen::Vector3f pigment(obj->pigment.x(), obj->pigment.y(), obj->pigment.z());
   Eigen::Vector3f l, v, h, lcol, dir;
   
   color = Eigen::Vector3f(0.0f, 0.0f, 0.0f);
   clr.r = clr.g = clr.b = 0.0;
   locateHeap.clear();
   sampleDistSqrd = newRadSqrd = INITIAL_SAMPLE_DIST_SQRD;
   
   normal = obj->getNormal(iPt, 2.0f);
   normal.normalize();
   
   v = start - iPt;
   v.normalize();
   dir = -v;

   Collision* col;
   bool shadow;
   
   absorbClr.r = reflectClr.r = refractClr.r = 0.0;
   absorbClr.g = reflectClr.g = refractClr.g = 0.0;
   absorbClr.b = reflectClr.b = refractClr.b = 0.0;
   
   colorD = pigment * obj->diffuse;
   colorS = pigment * obj->specular;
   colorA = pigment * obj->ambient;

   if (fabs(1.0f - obj->refraction) > TOLERANCE || depth <= 0) {
      
      /*for (int lightnum = 0; lightnum < lights.size(); lightnum++) {
         dots1 = dots2 = 0.0f;
         shadow = false;
         lcol = lights[lightnum]->getColor();
         lcol = Eigen::Vector3f(1.0f, 1.0f, 1.0f);
         l = (lights[lightnum]->getPosition() - iPt);
         mainDist = l.norm();
         l.normalize();
         h = (l + v);
         h.normalize();
         l.normalize();
         col = new Collision();
         col->detectRayCollision(iPt, l, objects, -1, unit);
         if (col->time >= TOLERANCE && (l*col->time).norm() < mainDist) shadow = true;
         delete(col);
         if (shadow == false) {
            dots1 = l.dot(normal);
            if (dots1 < TOLERANCE) { 
               dots1 = 0.0f;
            }
            
            temp = dots2 = h.dot(normal);
            if (dots2 < TOLERANCE) { 
               dots2 = 0.0f;
            } else {
               for (int i = 0; i < int(reflectance); i++) {
            	   dots2 *= temp;
            	}
            }
         }
         color.x() += ((colorA.x() / float(lights.size())) + (colorD.x() * dots1) + (colorS.x() * dots2)) * lcol.x();
         color.y() += ((colorA.y() / float(lights.size())) + (colorD.y() * dots1) + (colorS.y() * dots2)) * lcol.y();
         color.z() += ((colorA.z() / float(lights.size())) + (colorD.z() * dots1) + (colorS.z() * dots2)) * lcol.z();
      }*/
      reflectScale = obj->reflection;
      
      if (abs(ELLIPSOID_SCALE - 1.0) > TOLERANCE &&
          (abs(abs(normal[0]) - eRay[0]) > TOLERANCE ||
           abs(abs(normal[1]) - eRay[1]) > TOLERANCE ||
           abs(abs(normal[2]) - eRay[2]) > TOLERANCE)) {
         crossP = eRay.cross(normal);
         crossP.normalize();
         x = crossP.x(); y = crossP.y(); z = crossP.z();
         c = eRay.dot(normal); s = sin(acos(eRay.dot(normal))); t = 1.0 - c;
         mat << t*x*x + c, t*x*y - z*s, t*x*z + y*s,
                t*x*y + z*s, t*y*y + c, t*y*z - x*s,
                t*x*z - y*s, t*y*z + x*s,	t*z*z + c;
         matInv = mat.inverse();
      } else {
         matInv << 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0;
      }
      if (numCPhotons > 0) rootC1->locatePhotons(1, iPt, &locateHeap, 0.05, &newRadSqrd, matInv, numCPhotons);
      causts = locateHeap.size();
      if (numGPhotons > 0) root->locatePhotons(1, iPt, &locateHeap, sampleDistSqrd, &newRadSqrd, matInv, numGPhotons);
      
      for (int i = 0; i < locateHeap.size(); i++) {
         //BRDF
         if (i < causts) {
            d = (locateHeap[i]->pt - iPt).norm();
            w = alpha * (1 - ((1 - pow(e, -1 * beta * ((d * d) / (2 * newRadSqrd)))) / (1 - pow(e, -1 * beta))));
            color += (locateHeap[i]->intensity) * std::max((-locateHeap[i]->incidence).dot(normal), 0.0f);// * w;//* (1.0 - ((locateHeap[i]->pt - intersectPt).norm() / sqrt(newRadSqrd)));
         } else {
            color += (locateHeap[i]->intensity) * std::max((-locateHeap[i]->incidence).dot(normal), 0.0f);
         }
      }
      color /= newRadSqrd * M_PI;
      
      color *= (1.0 - obj->reflection) * scale;
      absorbClr.r = color.x();
      absorbClr.g = color.y();
      absorbClr.b = color.z();
      
   } else {
      if (depth > 0) {         
         //Do Refraction
         reflectRay = findRefract(dir, normal, obj, n1, &n2, &reflectScale, &tempDO);
         if (fabs(reflectScale - 1.0f) >= TOLERANCE) { //Total internal reflection carry-over check
            col = trace(iPt, reflectRay, unit);
            if (col->time >TOLERANCE) {
               refractClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * (1.0f - reflectScale), n2, tempDO, depth - 1);
            }
            delete(col);
         }
      }
   }

   if ((obj->reflection > TOLERANCE || fabs(obj->refraction - 1.0) < TOLERANCE) && depth > 0) {
      float randFloat;
      reflectRay = findReflect(dir, normal, obj);
      col = trace(iPt, reflectRay, unit);
      if (col->time >= TOLERANCE) {
         reflectClr = calcRadiance(iPt, iPt + reflectRay * col->time, col->object, unit, scale * reflectScale, n1, dropoff, depth - 1);
      }
      delete(col);
   }

   time = (iPt - start).norm();
   float dropoffCalc = pow(dropoff, time);
   clr.r += (absorbClr.r + reflectClr.r + refractClr.r) * dropoffCalc;
   clr.g += (absorbClr.g + reflectClr.g + refractClr.g) * dropoffCalc;
   clr.b += (absorbClr.b + reflectClr.b + refractClr.b) * dropoffCalc;
   
	return clr;
}
                  
Eigen::Vector3f RayTracer::findReflect(Eigen::Vector3f ray, Eigen::Vector3f normal, SceneObject* obj) {
   Eigen::Vector3f reflectRay;
   
   reflectRay = ray + (2.0*normal*(normal.dot(-ray)));
   reflectRay.normalize();
   
   return reflectRay;
}

Eigen::Vector3f RayTracer::findRefract(Eigen::Vector3f ray, Eigen::Vector3f normalI, SceneObject* obj, float n1, float* n2, float* R, float* dropoff) {
   Eigen::Vector3f refractRay, normal = normalI;
   float dots1, R0, sroot, innersqr;
   
   //Determine object-ray status
   dots1 = (-ray).dot(normal);
   if (dots1 < 0.0f) { //Exitting
      *n2 = 1.0f; //Assume no refract object collision
      *dropoff = 1.0f;
      normal *= -1.0f;
      dots1 = (-ray).dot(normal);
   } else { //Entering
      *n2 = obj->indexRefraction;
      *dropoff = obj->dropoff;
   }
   
   sroot = 1.0f - ((n1 / *n2) * (n1 / *n2) * (1.0f - (dots1 * dots1)));
   if (sroot < 0.0f) { //Total internal reflection check
      *R = 1.0f;
   } else {
      //Schlick Overhead
      R0 = (n1 - *n2) / (n1 + *n2);
      R0 *= R0;
      
      innersqr = 1.0f - dots1;
      innersqr = pow(innersqr, 5);
      *R = R0 + ((1.0f - R0) * innersqr);
      
      refractRay = ((n1 / *n2) * (ray + (normal * dots1))) - (normal * sqrt(sroot));
      refractRay.normalize();
   }
   
   return refractRay;
}
