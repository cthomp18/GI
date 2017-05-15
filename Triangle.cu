/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include "glm/glm.hpp"
#include "glm/gtc/type_ptr.hpp"
#include "Triangle.h"

Triangle::Triangle(glm::vec3 pt1, glm::vec3 pt2, glm::vec3 pt3) : SceneObject() {
   a = pt1;
   b = pt2;
   c = pt3;
   
   normal = glm::cross(b - a, c - a);
   normal = glm::normalize(normal);
   smooth = false;
   type = 3;
   
   checkCollision = (&checkTriCollision);
   getNormal = (&getTriNormal);
}

Triangle::Triangle(glm::vec3 pt1, glm::vec3 pt2, glm::vec3 pt3, bool smoothCheck) : SceneObject() {
   a = pt1;
   b = pt2;
   c = pt3;
   
   normal = glm::cross(b - a, c - a);
   normal = glm::normalize(normal);
   smooth = false;
   
   if (smoothCheck) {
      smooth = true;
      glm::vec3 v1 = b - a, v2 = c - a;
      dotAB = glm::dot(v1, v1);
      dotAC = glm::dot(v2, v2);
      dotABC = glm::dot(v1, v2);
      multiplier = 1.0f / ((dotAB * dotAC) - (dotABC * dotABC));
   }
   
   checkCollision = (&checkTriCollision);
   getNormal = (&getTriNormal);
}

Triangle::Triangle() : SceneObject() {}
Triangle::~Triangle() {
   //printf("yo dawg wuts gud\n");
}

Triangle::Triangle(Triangle* o) : SceneObject() {
   a = o->a;
   b = o->b;
   c = o->c;
   aNor = o->aNor;
   bNor = o->bNor;
   cNor = o->cNor;
   
   dotAB = o->dotAB;
   dotAC = o->dotAC;
   dotABC = o->dotABC;
   multiplier = o->multiplier;
      
   normal = o->normal;
   smooth = o->smooth;
   
   checkCollision = (&checkTriCollision);
   getNormal = (&getTriNormal);
   
   copyData(o);
}

/*float Triangle::checkCollision(glm::vec3 start, glm::vec3 ray, float time) {
   std::cout << "Triangle Collision" << std::endl;
   glm::mat3 A, Ai;
   double detA, t, beta, gamma;
   A = glm::mat3(a.x - b.x, a.x - c.x, ray.x,
                 a.y - b.y, a.y - c.y, ray.y,
                 a.z - b.z, a.z - c.z, ray.z);
   detA = glm::determinant(A);
   //std::cout << "making sure lol" << std::endl;
   //std::cout << detA << std::endl;
   //if (std::fabs(detA) > 0.0f) {
      //std::cout << "hi?" << std::endl;
      Ai = A;
      Ai[0][2] = a.x - start.x; Ai[1][2] = a.y - start.y; Ai[2][2] = a.z - start.z;
      t = glm::determinant(Ai) / detA;
      if (t > TOLERANCE) {
         //std::cout << "hiya" << std::endl;
         Ai = A;
         Ai[0][0] = a.x - start.x; Ai[1][0] = a.y - start.y; Ai[2][0] = a.z - start.z;
         gamma = glm::determinant(Ai) / detA;
         if (gamma >= 0.0f && gamma <= 1.0f) {
            //std::cout << "hello" << std::endl;
            Ai = A;
            Ai[0][1] = a.x - start.x; Ai[1][1] = a.y - start.y; Ai[2][1] = a.z - start.z;
            beta = glm::determinant(Ai) / detA;
            //std::cout << "Beta: " << beta << " Gamma: " << gamma << std::endl;
            if (beta >= 0.0f && beta + gamma <= 1.0f) {
               //std::cout << t << std::endl;
               return t;
            }
         }
      }
   //}
   
   return -1.0f;
}*/

/*glm::vec3 Triangle::getNormal(glm::vec3 iPt, float time) {
   float alpha, beta, gamma;
   glm::vec3 normalConstructor = normal;
   printf("sup dawg\n");
   if (smooth) {
      float dotABP = glm::dot(b - a, iPt - a), dotACP = glm::dot(c - a, iPt - a);
      alpha = ((dotAC * dotABP) - (dotABC * dotACP)) * multiplier;
      beta = ((dotAB * dotACP) - (dotABC * dotABP)) * multiplier;
      gamma = (1.0f - alpha) - beta;
      
      normalConstructor = bNor * alpha;
      normalConstructor += cNor * beta;
      normalConstructor += aNor * gamma;
      normalConstructor = glm::normalize(normalConstructor);
   }
   
   return normalConstructor;
}*/

void Triangle::constructBB() {
   glm::vec3 minPt = glm::vec3(FLT_MAX, FLT_MAX, FLT_MAX);
   glm::vec3 maxPt = glm::vec3(FLT_MIN, FLT_MIN, FLT_MIN);
   
   for (int i = 0; i < 3; i++) {
      minPt[i] = fmin(fmin(a[i], b[i]), c[i]);
      maxPt[i] = fmax(fmax(a[i], b[i]), c[i]);
   }
   
   boundingBox = BoundingBox(minPt, maxPt);
}

void Triangle::printObj() {
   std::cout << a.x << " " << a.y << " " << a.z << std::endl;
   std::cout << b.x << " " << b.y << " " << b.z << std::endl;
   std::cout << c.x << " " << c.y << " " << c.z << std::endl;
}
