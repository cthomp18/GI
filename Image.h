/**
 * Bob Somers
 * rsomers@calpoly.edu
 * CPE 473, Winter 2010
 * Cal Poly, San Luis Obispo
 */

#ifndef __IMAGE_H__
#define __IMAGE_H__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "types.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp" //perspective, trans etc
#include "glm/gtc/type_ptr.hpp" //value_ptr
#include "glm/gtx/string_cast.hpp"

class Image {
public:
    Image(int width, int height);
    ~Image();

    // if scale_color is true, the output targa will have its color space scaled
    // to the global max, otherwise it will be clamped at 1.0
    void WriteTga(char *outfile, bool scale_color = true);

    void GenTestPattern();

    // property accessors
    glm::vec3 pixel(int x, int y);
    void pixel(int x, int y, glm::vec3 pxl);
    int width() const { return _width; }
    int height() const { return _height; }
    double max() const { return _max; }

private:
    int _width;
    int _height;
    color_t **_pixmap;
    double _max;
};

#endif

