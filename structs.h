#ifndef __StructsPM__
#define __StructsPM__

#include "types.h"

#define GLOBALPHOTONS 100000
#define CAUSTICPHOTONS 200000
#define TOLERANCE 0.001
#define CUTOFF_HEAP_SIZE 10000
#define INITIAL_SAMPLE_DIST_SQRD 0.5
#define ELLIPSOID_SCALE 0.2
#define AIR_REFRACT_INDEX 1.0000000000000f
#define GLASS_REFRACT_INDEX 1.500000000000f
#define DEPTH 2

typedef struct Pixel {
   glm::vec3 pt;
   glm::vec3 clr;
} Pixel;

#endif
