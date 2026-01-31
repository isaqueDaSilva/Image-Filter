//
//  ImageRepresentable.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import PhotosUI
import SwiftUI

struct ImageRepresentable: Transferable, Equatable {
    let image: DefaultImage
    let applyedFilter: Filter?
    let applyedAdjustments: Adjustment?
    let levelOfAdjustment: Float
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let defaultImage = DefaultImage(data: data) else {
                throw ImageRepresentableError.importFailed
            }
            
            return await MainActor.run {
                #if canImport(UIKit)
                let normalized = defaultImage.normalizedUpOrientation()
                return Self(from: normalized)
                #else
                return Self(from: defaultImage)
                #endif
            }
        }
    }
    
    init(from originalImage: DefaultImage, applyedFilter: Filter? = nil, applyedAdjustments: Adjustment? = nil, levelOfAdjustment: Float = 0) {
        self.image = originalImage
        self.applyedFilter = applyedFilter
        self.applyedAdjustments = applyedAdjustments
        self.levelOfAdjustment = levelOfAdjustment
    }
}
