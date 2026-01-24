//
//  ImageKit.cpp
//  Image Filter
//
//  Created by Isaque da Silva on 1/23/26.
//

#include "ImageKit.hpp"
#include <iostream>
#include <cmath>

void ImageKit::apply_inverse(void *buffer, int height, int width, int row_bytes) {
    // gets the memory adress of the top left image pixel.
    uint8_t *top_left_pixel_buffer = static_cast<uint8_t*>(buffer);
    
    // how many bytes each pixel channel have.
    const int bytes_per_pixel = 3;
    
    for (int y = 0; y < height; y++) {
        // Calculates the total displacement, in bytes,
        // to move in y axes and get the left pixel of the row.
        uint8_t *row = top_left_pixel_buffer + y * row_bytes;
        
        for (int x = 0; x < width; x++) {
            // Calculates the total diplacement, in bytes,
            // to move from the left, up to a desired pixel channel sequence.
            uint8_t *channels = row + x * bytes_per_pixel;
            
            channels[0] = 255 - channels[0]; // Red channel
            channels[1] = 255 - channels[1]; // Green channel
            channels[2] = 255 - channels[2]; // Blue channel
        }
    }
};

void ImageKit::apply_brightness(void *buffer, int height, int width, int row_bytes, float gamma) {
    uint8_t *top_left_pixel_buffer = static_cast<uint8_t*>(buffer);
    const int bytes_per_pixel = 3;
    
    for (int y = 0; y < height; y++) {
        uint8_t *row = top_left_pixel_buffer + y * row_bytes;
        
        for (int x = 0; x < width; x++) {
            uint8_t *channels = row + x * bytes_per_pixel;
            
            channels[0] = apply_gamma(channels[0], gamma); // Red channel
            channels[1] = apply_gamma(channels[1], gamma); // Green channel
            channels[2] = apply_gamma(channels[2], gamma); // Blue channel
        }
    }
};

uint8_t ImageKit::apply_gamma(uint8_t channel, float gamma) {
    // Normalize the channel value
    float scale = 1.0f / 255.0f;
    float channel_scalled = static_cast<float>(channel) * scale;
    
    // Calculates the gamma correction(y = ax^γ) for the channel.
    float new_scale = std::pow(channel_scalled, gamma);
    float new_value = 255.0f * new_scale;
    
    return static_cast<uint8_t>(new_value);
};
