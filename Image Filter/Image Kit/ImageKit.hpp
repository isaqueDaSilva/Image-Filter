//
//  ImageKit.hpp
//  Image Filter
//
//  Created by Isaque da Silva on 1/23/26.
//

#ifndef ImageKit_hpp
#define ImageKit_hpp

#include <stdio.h>
#include <iostream>
#include <cmath>

class ImageKit {
public:
    static void apply_inverse(void* buffer, int height, int width, int row_bytes);
    static void apply_brightness(void *buffer, int height, int width, int row_bytes, float gamma);
private:
    static uint8_t apply_gamma(uint8_t channel, float gamma);
};

#endif /* ImageKit_hpp */
