//
//  Filter.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Accelerate
import Foundation
import SwiftUI

struct Filter { }

extension Filter {
    enum Negative {
        static func apply(at image: DefaultImage) throws(ImageRepresentableError) -> DefaultImage {
            var buffer = try image.getPixelBuffer()
            processingNegative(buffer: &buffer)
            
            guard let imageFormat = vImage_CGImageFormat(
                bitsPerComponent: 8,
                bitsPerPixel: 8 * 4,
                colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
                bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))
            else {
                throw .formatterNotAvailable
            }
            
            do {
                let negativeImage = try buffer.createCGImage(format: imageFormat)
                #if canImport(UIKit)
                return .init(cgImage: negativeImage)
                #elseif canImport(AppKit)
                return .init(cgImage: negativeImage, size: buffer.size)
                #endif
            } catch {
                throw .failedToCreateCGImage
            }
        }
        
        private static func processingNegative(buffer: inout vImage_Buffer) {
            let height = Int32(buffer.height)
            let width = Int32(buffer.width)
            let rowBytes = Int32(buffer.rowBytes)
            
            apply_negative(buffer.data, height, width, rowBytes)
        }
    }
}
