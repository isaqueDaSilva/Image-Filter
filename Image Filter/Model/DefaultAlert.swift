//
//  DefaultAlert.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/18/26.
//

enum DefaultAlert {
    case savePhoto, cleanCache
    
    var title: String {
        switch self {
        case .savePhoto:
            return "Save Photo"
        case .cleanCache:
            return "Clean Photo"
        }
    }
    
    var description: String {
        switch self {
        case .savePhoto:
            return "This action will be save the image in your photo library."
        case .cleanCache:
            return "When you confirm this action, you won't be able to return at the current state."
        }
    }
}
