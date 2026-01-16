//
//  Image+Extension.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Accelerate
import SwiftUI

#if canImport(UIKit)
typealias DefaultImage = UIImage
#elseif canImport(AppKit)
typealias DefaultImage = NSImage
#endif

extension DefaultImage {
    var cgImageCoverter: CGImage? {
        #if canImport(UIKit)
        return self.cgImage
        #elseif canImport(AppKit)
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
    
    var swiftuiImage: Image {
        .init(self)
    }
    
    func getPixelBuffer() throws(ImageRepresentableError) -> vImage_Buffer {
        guard let cgImage = self.cgImageCoverter else {
            throw .convertionFailed
        }
        
        guard let imageFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))
        else {
            throw .formatterNotAvailable
        }
        
        do {
            // A buffer that stores image's data like pixel data, number of channels and more
            return try vImage_Buffer(cgImage: cgImage, format: imageFormat)
        } catch {
            throw .convertionFailed
        }
    }
}

extension Image {
    init(_ defaultImage: DefaultImage) {
        #if canImport(UIKit)
        self.init(uiImage: defaultImage)
        #elseif canImport(AppKit)
        self.init(nsImage: defaultImage)
        #endif
    }
}
