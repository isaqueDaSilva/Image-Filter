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
        static func apply(at image: DefaultImage) async throws(ImageRepresentableError) -> DefaultImage {
            var buffer = try image.getPixelBuffer()
            processingNegative(buffer: &buffer)
            
            let imageFormat = try buildFormat()
            
            return try createImage(from: buffer, and: imageFormat)
        }
        
        private static func buildFormat() throws(ImageRepresentableError) -> vImage_CGImageFormat {
            guard let imageFormat = vImage_CGImageFormat(
                bitsPerComponent: 8,
                bitsPerPixel: 8 * 4,
                colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
                bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))
            else {
                throw .formatterNotAvailable
            }
            
            return imageFormat
        }
        
        private static func processingNegative(buffer: inout vImage_Buffer) {
            let height = Int32(buffer.height)
            let width = Int32(buffer.width)
            let rowBytes = Int32(buffer.rowBytes)
            
            apply_negative(buffer.data, height, width, rowBytes)
        }
        
        private static func createImage(from buffer: vImage_Buffer, and imageFormat: vImage_CGImageFormat) throws(ImageRepresentableError) -> DefaultImage {
            do {
                let negativeImage = try buffer.createCGImage(format: imageFormat)
                buffer.free()
                #if canImport(UIKit)
                return .init(cgImage: negativeImage)
                #elseif canImport(AppKit)
                return .init(cgImage: negativeImage, size: buffer.size)
                #endif
            } catch {
                print(error.localizedDescription)
                throw .failedToCreateCGImage
            }
        }
    }
}
