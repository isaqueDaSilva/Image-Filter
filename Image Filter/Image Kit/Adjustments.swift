//
//  Adjustments.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/24/26.
//

import Accelerate
import Foundation
import SwiftUI

struct Adjustments { }

extension Adjustments {
    enum Brightness {
        static func applyBrightnessAdjustment(
            for defaultImage: DefaultImage,
            with gamma: Float
        ) async throws(ImageRepresentableError) -> DefaultImage {
            var buffer = try defaultImage.getPixelBuffer()
            proccessBrightnessAdjustment(at: &buffer, with: gamma)
            return try buffer.recreateImage(with: .rgbFormat)
        }
        
        static private func proccessBrightnessAdjustment(at buffer: inout vImage_Buffer, with gamma: Float) {
            let height = Int32(buffer.height)
            let width = Int32(buffer.width)
            let rowBytes = Int32(buffer.rowBytes)
            
            ImageKit.apply_brightness(buffer.data, height, width, rowBytes, gamma)
        }
    }
}
