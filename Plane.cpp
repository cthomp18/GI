/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Plane.h"

Plane::Plane(Eigen::Vector3f n, float d) : SceneObject() {
   normal = n;
   normal.normalize();
   distance = d;
   planePt = normal * distance;
}

Plane::Plane() : SceneObject() {}
Plane::~Plane() {}

float Plane::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   float t = -1.0f;
   Eigen::Vector3f origin = Eigen::Vector3f(0.0f, 0.0f, 0.0f);
   
   if (ray.dot(normal) != 0.0f) {
      t = (planePt - start).dot(normal) / (ray.dot(normal));
   }
   
   return t;
   /*float t = -1.0f, tAccrue = 0.0f;
   
   //Ray Marching Boys
   
   Eigen::Vector3f pt0 = start; //Current point
   Eigen::Vector3f pt1 = start; //Next point
   Eigen::Vector3f ptW = planePt + (pt1 - Eigen::Vector3f(normal.x() * pt1.x(), normal.y() * pt1.y(), normal.z() * pt1.z()));//getPoint(pt1.x(), pt1.z(), time); //Point on wave with same x, z (i think)
   //Eigen::Vector3f normal; //Normal of said point on wave
   float step = 2.0f; //Current step (May or may not go through wave if (near) parallel to y plane)
   
   float povertwo = M_PI / 2.0f;
   if (ray.dot(normal) >= 0.0) return t;
   while (fabs(pt1.y() - ptW.y()) > TOLERANCE || fabs(pt1.x() - ptW.x()) > TOLERANCE || fabs(pt1.z() - ptW.z()) > TOLERANCE) {
      if (tAccrue > 22.0f) return t;
      //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "ptW: " << ptW.x() << " " << ptW.y() << " " << ptW.z() << " pt1: " << pt1.x() << " " << pt1.y() << " " << pt1.z() << std::endl;
      //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "dotthing: " << normal.dot(pt1 - ptW) << std::endl;
      //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "tAcc " << tAccrue << std::endl;
      if (normal.dot(pt1 - ptW) < 0.0f) { //If pt1 on the other side of the wave
         //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "ptW: " << ptW.x() << " " << ptW.y() << " " << ptW.z() << " pt1: " << pt1.x() << " " << pt1.y() << " " << pt1.z() << std::endl;
         //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "dotthing: " << acos(normal.dot((pt1 - ptW) / (pt1 - ptW).norm())) << std::endl;
         //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "tAcc " << tAccrue << std::endl;
         //if (abs(normal.y() - 1.0) < TOLERANCE) std::cout << "HIYYA " << tAccrue << " " << step << std::endl;
         pt1 = pt0;
         tAccrue -= step;
         step /= 4.0f;
      } else {
         tAccrue += step;
      }
      
      pt0 = pt1;
      pt1 = start + (ray * tAccrue);
      //ptW = getPoint(pt1.x(), pt1.z(), time);
      ptW = planePt + (pt1 - Eigen::Vector3f(fabs(normal.x()) * pt1.x(), fabs(normal.y()) * pt1.y(), fabs(normal.z()) * pt1.z()));
      //normal = getNormal(ptW, time);
   }
   
   t = tAccrue;
   return t;*/
}

Eigen::Vector3f Plane::getNormal(Eigen::Vector3f iPt, float time) {
   return normal;
}
