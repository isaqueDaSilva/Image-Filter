//
//  ImageRepresentableError.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Foundation

enum ImageRepresentableError: Error {
    case importFailed, convertionFailed, formatterNotAvailable, failedToCreateCGImage
}
