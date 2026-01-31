//
//  Adjustment.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/24/26.
//

import Accelerate
import Foundation
import SwiftUI

enum Adjustment: String, CaseIterable, Identifiable {
    case brightness
    
    var id: String {
        self.rawValue
    }
    
    var rawValue: String {
        switch self {
        case .brightness:
            "Brightness"
        }
    }
    
    var rangeValue: ClosedRange<Float> {
        switch self {
        case .brightness:
            0.5 ... 2.2
        }
    }
    
    var normalValue: Float {
        switch self {
        case .brightness:
            1
        }
    }
}

extension Adjustment {
    static func applyBrightnessAdjustment(
        for defaultImage: DefaultImage,
        with gamma: Float
    ) async throws(ImageRepresentableError) -> DefaultImage {
        var buffer = try defaultImage.getPixelBuffer()
        proccessBrightnessAdjustment(at: &buffer, with: 1 / gamma)
        return try buffer.recreateImage(with: .rgbFormat)
    }
    
    static private func proccessBrightnessAdjustment(at buffer: inout vImage_Buffer, with gamma: Float) {
        let height = Int32(buffer.height)
        let width = Int32(buffer.width)
        let rowBytes = Int32(buffer.rowBytes)
        
        ImageKit.apply_brightness(buffer.data, height, width, rowBytes, gamma)
    }
}
