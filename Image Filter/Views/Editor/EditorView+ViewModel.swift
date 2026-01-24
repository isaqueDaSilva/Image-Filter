//
//  EditorView+ViewModel.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/18/26.
//

import PhotosUI
import SwiftUI

extension EditorView {
    @Observable
    @MainActor
    final class ViewModel {
        private var processTask: Task<Void, Never>?
        private var photoLibraryGeterTask: Task<Void, Never>?
        
        private(set) var imageState: ImageState = .empty
        var selectedImage: DefaultImage?
        
        var isShowingBrightnessSlider = false
        var sliderValue: Float = 1.0
        
        var cache: [DefaultImage] = []
        var currentImageIndex = 0
        let maximumNumberOfImages = 5
        
        var error: ImageRepresentableError?
        var isShowingError = false
        
        var alert: DefaultAlert? = nil
        var isShowingAlert = false
        
        var imageSelection: PhotosPickerItem? = nil {
            didSet {
                if let imageSelection {
                    loadTransferable(from: imageSelection)
                } else {
                    imageState = .empty
                }
            }
        }
    }
}

// MARK: Alerts
extension EditorView.ViewModel {
    func showAlert(_ alert: DefaultAlert) {
        self.alert = alert
        self.isShowingAlert = true
    }
}

// MARK: - Cache Handler
extension EditorView.ViewModel {
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
            cache.remove(at: 1) // Removes the first photo with a filter applied
        }
        
        cache.append(newImage)
        
        currentImageIndex = cache.count - 1
    }
    
    func emptyCache() {
        cache.removeAll()
        currentImageIndex = 0
        selectedImage = nil
        imageSelection = nil
        imageState = .empty
    }
}

// MARK: - Get Photos
extension EditorView.ViewModel {
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        imageState = .loading
        
        photoLibraryGeterTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let representable = try await imageSelection.loadTransferable(type: ImageRepresentable.self)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let representable {
                        self.imageState = .success
                        let image = representable.image
                        self.appendAtCache(newImage: image)
                        self.selectedImage = image
                    } else {
                        self.imageState = .empty
                    }
                }
            } catch {
                print(error.localizedDescription)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.error = .importFailed
                    self.imageState = .failure
                    self.isShowingError = true
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                photoLibraryGeterTask?.cancel()
                photoLibraryGeterTask = nil
            }
        }
    }
}

// MARK: - Filters wrapper
extension EditorView.ViewModel {
    func showBrightnessSlider() {
        isShowingBrightnessSlider = true
    }
    
    private func stopExecution() async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            processTask?.cancel()
            processTask = nil
        }
    }
    
    private func updateCache(with newImage: DefaultImage) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            appendAtCache(newImage: newImage)
            self.selectedImage = newImage
            imageState = .success
        }
    }
    
    private func setError(error: ImageRepresentableError?) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            imageState = .failure
            self.error = error
            self.isShowingError = true
        }
    }
    
    func applyNegativeFilter() {
        guard processTask == nil else { return }
        
        processTask?.cancel()
        
        processTask = Task.detached { [weak self] in
            guard let self, let selectedImage = await selectedImage else {
                await self?.stopExecution()
                return
            }
            
            do {
                let newImage = try await Filter.ColorInversion.apply(at: selectedImage)
                
                await updateCache(with: newImage)
            } catch {
                await setError(error: error as? ImageRepresentableError)
            }
            
            await stopExecution()
        }
    }
    
    func adjustBrightness() {
        guard processTask == nil else { return }
        
        processTask?.cancel()
        
        processTask = Task.detached { [weak self] in
            guard let self, let selectedImage = await cache.first else {
                await self?.stopExecution()
                return
            }
            
            do {
                let newImage = try await Adjustments.Brightness.applyBrightnessAdjustment(
                    for: selectedImage,
                    with: sliderValue
                )
                
                await updateCache(with: newImage)
            } catch {
                await setError(error: error as? ImageRepresentableError)
            }
            
            await stopExecution()
        }
    }
}
