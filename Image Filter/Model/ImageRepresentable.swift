//
//  ImageRepresentable.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import PhotosUI
import SwiftUI

struct ImageRepresentable: Transferable {
    let image: DefaultImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let defaultImage = DefaultImage(data: data) else {
                throw ImageRepresentableError.importFailed
            }
            
            return await MainActor.run {
                return Self(from: defaultImage)
            }
        }
    }
    
    init(from defaultImage: DefaultImage) {
        self.image = defaultImage
    }
}
