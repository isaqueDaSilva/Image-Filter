//
//  vImage_Buffer+Extension.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/24/26.
//

import Accelerate
import SwiftUI

extension vImage_Buffer {
    func recreateImage(with imageFormat: vImage_CGImageFormat) throws(ImageRepresentableError) -> DefaultImage {
        do {
            let newImage = try self.createCGImage(format: imageFormat)
            self.free()
            #if canImport(UIKit)
            return .init(cgImage: newImage)
            #elseif canImport(AppKit)
            return .init(cgImage: newImage, size: self.size)
            #endif
        } catch {
            print(error.localizedDescription)
            throw .failedToCreateCGImage
        }
    }
}
