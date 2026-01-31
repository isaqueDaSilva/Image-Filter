//
//  PhotoLibraryHandler.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import Foundation
import Photos

@Observable
final class PhotoLibraryHandler {
    private(set) var readWriteAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    func checkAuthorizationStatus() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .notDetermined {
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                readWriteAuthorizationStatus = newStatus
            }
            
            return
        } else {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                readWriteAuthorizationStatus = status
            }
        }
    }
    
    func saveImage(_ image: DefaultImage) -> ImageRepresentableError? {
        guard readWriteAuthorizationStatus == .authorized else { return .photoLibraryAccessDenied }
        
        var saveError: ImageRepresentableError?
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            saveError = nil
        } completionHandler: { isSuccesseded, error in
            if !isSuccesseded {
                print(error?.localizedDescription ?? "No Error.")
                saveError = .failedToSaveImage
            }
        }
        
        return saveError
    }
}
