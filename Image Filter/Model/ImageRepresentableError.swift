//
//  ImageRepresentableError.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Foundation

enum ImageRepresentableError: Error {
    case importFailed, convertionFailed, formatterNotAvailable, failedToCreateCGImage
    
    var title: String {
        switch self {
        case .importFailed:
            "Failed to import Image"
        case .convertionFailed, .formatterNotAvailable, .failedToCreateCGImage:
            "Internal error"
        }
    }
    
    var description: String {
        switch self {
        case .importFailed:
            "The image you selected from your library did not load correctly. Please select it again or contact us."
        case .convertionFailed, .formatterNotAvailable, .failedToCreateCGImage:
            "An internal error happened. Please try to repeat the action or contact us."
        }
    }
}
