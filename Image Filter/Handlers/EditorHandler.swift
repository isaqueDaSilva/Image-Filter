//
//  EditorHandler.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import Foundation
import PhotosUI
import SwiftUI

@Observable
@MainActor
final class EditorHandler {
    private(set) var imageState: ImageState = .empty
    
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                loadTransferable(from: imageSelection)
                imageState = .loading
            } else {
                imageState = .empty
            }
        }
    }
    
    var cache: [DefaultImage] = []
    var selectedImage: DefaultImage?
    var currentImageIndex = 0
    
    let maximumNumberOfImages = 5
    private var filterTask: Task<Void, Never>?
}

// MARK: Load Image from default library
extension EditorHandler {
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        imageSelection.loadTransferable(type: ImageRepresentable.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let representable?):
                    self.imageState = .success
                    let image = representable.image
                    self.appendAtCache(newImage: image)
                    self.selectedImage = image
                case .success(nil):
                    self.imageState = .empty
                case .failure(_):
                    self.imageState = .failure
                }
            }
        }
    }
}

// MARK: Cache Handle
extension EditorHandler {
    func nextImage() {
        guard currentImageIndex < 4 && currentImageIndex < cache.count - 1 else { return }
        currentImageIndex += 1
        selectedImage = cache[currentImageIndex]
    }
    
    func previousImage() {
        guard currentImageIndex > 0 else { return }
        currentImageIndex -= 1
        selectedImage = cache[currentImageIndex]
    }
    
    private func appendAtCache(newImage: DefaultImage) {
        if cache.count >= maximumNumberOfImages {
            cache.removeFirst()
        }
        
        cache.append(newImage)
        
        currentImageIndex = cache.count - 1
    }
    
    func emptyCache() {
        cache.removeAll()
        currentImageIndex = 0
        selectedImage = nil
        imageState = .empty
    }
}

// MARK: Apply Negative Filter
extension EditorHandler {
    func applyNegativeFilter() {
        guard let selectedImage, filterTask == nil else { return }
        
        imageState = .loading
        
        filterTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let newImage = try Filter.Negative.apply(at: selectedImage)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    appendAtCache(newImage: newImage)
                    self.selectedImage = newImage
                    imageState = .success
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    imageState = .failure
                }
                print(error.localizedDescription)
            }
            
            filterTask?.cancel()
            filterTask = nil
        }
    }
}
