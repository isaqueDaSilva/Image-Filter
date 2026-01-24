//
//  vImage_CGImageFormat+Extension.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/24/26.
//

import Accelerate

extension vImage_CGImageFormat {
    static var rgbFormat: Self {
        vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 3,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: .init(rawValue: CGImageAlphaInfo.none.rawValue)
        )!
    }
}
