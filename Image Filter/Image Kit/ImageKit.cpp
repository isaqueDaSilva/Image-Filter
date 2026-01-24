//
//  ImageKit.cpp
//  Image Filter
//
//  Created by Isaque da Silva on 1/23/26.
//

#include "ImageKit.hpp"
#include <iostream>

void apply_negative(void *buffer, int height, int width, int row_bytes) {
    // convert a void* pointer into a uint8* pointer
    uint8_t* pixels_buffer = static_cast<uint8_t*>(buffer);
    
    // how many bytes each pixel channel have.
    const int bytes_per_pixel = 4;
    
    // interates in each pixel to get channel informations
    // and apply a negative formula, skipping alpha channel.
    for (int y = 0; y < height; y++) {
        // Calculates the total displacement, in bytes,
        // to move in x axes and get the current pixel row.
        uint8_t* row = pixels_buffer + y * row_bytes;
        
        for (int x = 0; x < width; x++) {
            // Calculates the total diplacement, in bytes,
            // to move from the left, up to a desired pixel channel sequence.
            uint8_t* pixels = row + x * bytes_per_pixel;
            
            pixels[1] = 255 - pixels[1]; // Red channel
            pixels[2] = 255 - pixels[2]; // Green channel
            pixels[3] = 255 - pixels[3]; // Blue channel
        }
    }
}
