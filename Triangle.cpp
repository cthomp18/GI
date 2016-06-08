/*
   Cody Thompson
   CPE 473: Rendering
   Spring 2016
*/

#include <Eigen/Dense>
#include "Triangle.h"

Triangle::Triangle(Eigen::Vector3f pt1, Eigen::Vector3f pt2, Eigen::Vector3f pt3) : SceneObject() {
   a = pt1;
   b = pt2;
   c = pt3;
   
   normal = (b - a).cross(c - a);
   normal.normalize();
}

Triangle::Triangle() : SceneObject() {}
Triangle::~Triangle() {}

float Triangle::checkCollision(Eigen::Vector3f start, Eigen::Vector3f ray, float time) {
   //std::cout << "Triangle Collision" << std::endl;
   Eigen::Matrix3f A, Ai;
   double detA, t, beta, gamma;
   A << a.x() - b.x(), a.x() - c.x(), ray.x(),
        a.y() - b.y(), a.y() - c.y(), ray.y(),
        a.z() - b.z(), a.z() - c.z(), ray.z();
   detA = A.determinant();
   //std::cout << "making sure lol" << std::endl;
   //std::cout << detA << std::endl;
   //if (std::fabs(detA) > 0.0f) {
      //std::cout << "hi?" << std::endl;
      Ai = A;
      Ai(0, 2) = a.x() - start.x(); Ai(1, 2) = a.y() - start.y(); Ai(2, 2) = a.z() - start.z();
      t = Ai.determinant() / detA;
      if (t > TOLERANCE) {
         //std::cout << "hiya" << std::endl;
         Ai = A;
         Ai(0, 0) = a.x() - start.x(); Ai(1, 0) = a.y() - start.y(); Ai(2, 0) = a.z() - start.z();
         gamma = Ai.determinant() / detA;
         if (gamma >= 0.0f && gamma <= 1.0f) {
            //std::cout << "hello" << std::endl;
            Ai = A;
            Ai(0, 1) = a.x() - start.x(); Ai(1, 1) = a.y() - start.y(); Ai(2, 1) = a.z() - start.z();
            beta = Ai.determinant() / detA;
            //std::cout << "Beta: " << beta << " Gamma: " << gamma << std::endl;
            if (beta >= 0.0f && beta + gamma <= 1.0f) {
               //std::cout << t << std::endl;
               return t;
            }
         }
      }
   //}
   
   return -1.0f;
}

Eigen::Vector3f Triangle::getNormal(Eigen::Vector3f iPt, float time) {
   return normal;
}

void Triangle::constructBB() {
   Eigen::Vector3f minPt = Eigen::Vector3f(FLT_MAX, FLT_MAX, FLT_MAX);
   Eigen::Vector3f maxPt = Eigen::Vector3f(FLT_MIN, FLT_MIN, FLT_MIN);
   
   for (int i = 0; i < 3; i++) {
      minPt[i] = fmin(fmin(a[i], b[i]), c[i]);
      maxPt[i] = fmax(fmax(a[i], b[i]), c[i]);
   }
   
   boundingBox = new Box(minPt, maxPt);
}
