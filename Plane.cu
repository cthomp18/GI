/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "Plane.h"

Plane::Plane(glm::vec3 n, float d) : SceneObject() {
   normal = n;
   normal = glm::normalize(normal);
   distance = d;
   planePt = normal * distance;
   checkCollision = &(checkPlaneCollision);
   getNormal = &(getPlaneNormal);
}

Plane::Plane() : SceneObject() {
   checkCollision = &(checkPlaneCollision);
   getNormal = &(getPlaneNormal);
}
Plane::~Plane() {}

/*float Plane::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   float t = -1.0f;
   //glm::vec3 origin = glm::vec3(0.0f, 0.0f, 0.0f);
   
   if (glm::dot(ray, normal) != 0.0f) {
      t = glm::dot(planePt - start, normal) / glm::dot(ray, normal);
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
//}

/*glm::vec3 Plane::getNormal(glm::vec3 iPt, float time) {
   return normal;
}*/
