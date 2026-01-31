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

extension UIImage {
    /// Returns an image whose pixel data is rendered in `.up` orientation.
    /// If the image is already `.up`, returns `self`.
    func normalizedUpOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
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
    
    func getPixelBuffer() throws(ImageRepresentableError) -> vImage_Buffer {
        guard let cgImage = self.cgImageCoverter else {
            throw .convertionFailed
        }
        
        do {
            return try vImage_Buffer(cgImage: cgImage, format: .rgbFormat)
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
