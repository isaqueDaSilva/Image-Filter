//
//  Filter.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Accelerate
import Foundation
import SwiftUI

enum Filter: String, CaseIterable, Identifiable {
    case original, colorInvertion
    
    var id: String {
        self.rawValue
    }
    
    var rawValue: String {
        switch self {
        case .original:
            "Original"
        case .colorInvertion:
            "Color Invertion"
        }
    }
    
    static var cacheKey: String = "Filter"
}

extension Filter {
    static func applyColorInversion(at image: DefaultImage) async throws(ImageRepresentableError) -> DefaultImage {
        var buffer = try image.getPixelBuffer()
        invertColors(buffer: &buffer)
        
        return try buffer.recreateImage(with: .rgbFormat)
    }
    
    private static func invertColors(buffer: inout vImage_Buffer) {
        let height = Int32(buffer.height)
        let width = Int32(buffer.width)
        let rowBytes = Int32(buffer.rowBytes)
        
        ImageKit.apply_inverse(buffer.data, height, width, rowBytes)
    }
}
