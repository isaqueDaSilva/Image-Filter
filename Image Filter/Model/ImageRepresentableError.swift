//
//  ImageRepresentableError.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Foundation

enum ImageRepresentableError: Error {
    case importFailed, convertionFailed, formatterNotAvailable, failedToCreateCGImage, failedToSaveImage, photoLibraryAccessDenied
    
    var title: String {
        switch self {
        case .importFailed:
            "Failed to import Image"
        case .convertionFailed, .formatterNotAvailable, .failedToCreateCGImage:
            "Internal error"
        case .failedToSaveImage:
            "Failed to save image"
        case .photoLibraryAccessDenied:
            "Photo Library Access Denied"
        }
    }
    
    var description: String {
        switch self {
        case .importFailed:
            "The image you selected from your library did not load correctly. Please select it again or contact us."
        case .convertionFailed, .formatterNotAvailable, .failedToCreateCGImage:
            "An internal error happened. Please try to repeat the action or contact us."
        case .failedToSaveImage:
            "Failed to save the edited image. Please try again or contact us."
        case .photoLibraryAccessDenied:
            "You need to allow access to your photo library to perform this action. Go to Settings > Image Filter > Photos and chooise the limited access or full access option."
        }
    }
}
