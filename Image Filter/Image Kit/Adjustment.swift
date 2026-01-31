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
    case none, increaseBrightness, decreaseBrightness
    
    var id: String {
        self.rawValue
    }
    
    var rawValue: String {
        switch self {
        case .none:
            "None"
        case .increaseBrightness:
            "Increase Brightness"
        case .decreaseBrightness:
            "Decrease Brightness"
        }
    }
}

extension Adjustment {
    static func applyIncreaseBrightness(for defaultImage: DefaultImage) async throws(ImageRepresentableError) -> DefaultImage {
        try await applyBrightnessAdjustment(for: defaultImage, with: 0.45)
    }
    
    static func applydecreaseBrightness(for defaultImage: DefaultImage) async throws(ImageRepresentableError) -> DefaultImage {
        try await applyBrightnessAdjustment(for: defaultImage, with: 2.2)
    }
    
    static private func applyBrightnessAdjustment(
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
