//
//  EditorView+ViewModel.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/18/26.
//

import AsyncAlgorithms
import OrderedCollections
import Observation
import PhotosUI
import SwiftUI

extension EditorView {
    @Observable
    @MainActor
    final class ViewModel {
        private var processTask: Task<Void, Never>?
        private var photoLibraryGeterTask: Task<Void, Never>?
        let originalImageKey = "ORIGINAL"
        
        private(set) var imageState: ImageState = .empty
        private(set) var representable: ImageRepresentable?
        
        var selectedFilter: Filter? = nil {
            didSet {
                if let filter = selectedFilter, filter != oldValue {
                    applyFilter(filter)
                }
            }
        }
        var selectedAdjustment: Adjustment? = nil {
            willSet(newAdjustment) {
                guard let newAdjustment else {
                    stopStream()
                    return
                }
                
                adjustmentLevelObserver = AsyncStream.makeStream(of: Float.self, bufferingPolicy: .bufferingNewest(1))
                
                if let currentAdjustmentLevel = cache[newAdjustment.rawValue]?.levelOfAdjustment {
                    adjustmentLevel = currentAdjustmentLevel
                } else {
                    adjustmentLevel = newAdjustment.normalValue
                }
                
                applyAdjustment(newAdjustment)
            }
            
            didSet {
                if let oldAdjustment = oldValue, let representable, selectedAdjustment == nil && representable != cache[originalImageKey] {
                    updateCache(with: representable, and: oldAdjustment.rawValue)
                    
                    stopStream()
                    stopExecution()
                }
            }
        }
        
        private var adjustmentLevelObserver: (stream: AsyncStream<Float>, continuation: AsyncStream<Float>.Continuation)?
        var adjustmentLevel: Float = 0 {
            didSet {
                if adjustmentLevel != oldValue {
                    adjustmentLevelObserver?.continuation.yield(adjustmentLevel)
                }
            }
        }
        
        private(set) var cache: OrderedDictionary<String, ImageRepresentable> = [:]
        private(set) var currentImageIndex = 0
        let maximumNumberOfImages = 5
        
        private(set) var error: ImageRepresentableError?
        var isShowingError = false
        
        private(set) var alert: DefaultAlert? = nil
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
        
        init() {
            cache.reserveCapacity(maximumNumberOfImages)
        }
        
        deinit {
            Task { @MainActor [weak self] in
                guard let self else { return }
                
                stopStream()
            }
        }
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
                        cache[originalImageKey] = representable
                        self.representable = representable
                        imageState = .success
                    } else {
                        imageState = .empty
                    }
                }
            } catch {
                print(error.localizedDescription)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    setError(.importFailed)
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.photoLibraryGeterTask?.cancel()
                self.photoLibraryGeterTask = nil
            }
        }
    }
}

// MARK: - Cache Handler
extension EditorView.ViewModel {
    func nextImage() {
        guard currentImageIndex < maximumNumberOfImages - 1 || currentImageIndex < cache.count - 1 else { return }
        currentImageIndex += 1
        representable = cache.elements[currentImageIndex].value
    }
    
    func previousImage() {
        guard currentImageIndex > 0 else { return }
        currentImageIndex -= 1
        
        representable = cache.elements[currentImageIndex].value
    }
    
    private func appendAtCache(newImage: ImageRepresentable, withKey key: String) {
        if cache.count == maximumNumberOfImages {
            cache.remove(at: 1)
        }
        
        cache[key] = newImage
        
        currentImageIndex = cache.count - 1
    }
    
    private func updateCache(with newImage: ImageRepresentable, and key: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            appendAtCache(newImage: newImage, withKey: key)
            self.representable = newImage
            imageState = .success
        }
    }
    
    func emptyCache() {
        stopStream()
        stopExecution(isPerformingCleanup: true)
        selectedFilter = nil
        selectedAdjustment = nil
        cache.removeAll()
        imageSelection = nil
        representable = nil
        currentImageIndex = 0
        imageState = .empty
    }
}

// MARK: Handlers
extension EditorView.ViewModel {
    private func stopExecution(isPerformingCleanup: Bool = false) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            processTask?.cancel()
            processTask = nil
            
            if !isPerformingCleanup {
                imageState = .success
            }
        }
    }
    
    private func stopStream() {
        Task {  @MainActor [weak self] in
            guard let self else { return }
            
            adjustmentLevelObserver?.continuation.finish()
            adjustmentLevelObserver = nil
        }
    }
    
    func showAlert(_ alert: DefaultAlert) {
        self.alert = alert
        isShowingAlert = true
    }
    
    func setError(_ error: ImageRepresentableError?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            self.error = error
            imageState = .failure
            self.isShowingError = true
        }
    }
}

// MARK: - Filters wrapper
extension EditorView.ViewModel {
    func applyFilter(_ filter: Filter) {
        switch filter {
        case .colorInvertion:
            invertImageColors()
        case .original:
            representable = cache[originalImageKey]
        }
    }
    
    func applyAdjustment(_ adjustiment: Adjustment) {
        guard processTask == nil else { return }
        
        processTask?.cancel()
        
        processTask = Task { [weak self] in
            guard let self, let adjustmentLevelObserver, let representable else {
                self?.stopStream()
                self?.stopExecution()
                return
            }
            
            for await value in adjustmentLevelObserver.stream
                .dropFirst() // Skips the first element that is defined when the property is defined.
                .filter({ $0 > 0 })
                .debounce(for: .seconds(0.5), clock: .suspending)
            {
                switch adjustiment {
                case .brightness:
                    await adjustBrightness(for: representable, with: value)
                }
            }
        }
    }
    
    private func invertImageColors() {
        guard processTask == nil else { return }
        
        processTask?.cancel()
        
        imageState = .loading
        
        processTask = Task { [weak self] in
            guard let self, let selectedImage = representable else {
                self?.stopExecution()
                return
            }
            
            do {
                let newImage = try await Filter.applyColorInversion(at: selectedImage.image)
                
                updateCache(with: .init(from: newImage, applyedFilter: .colorInvertion), and: Filter.cacheKey)
            } catch {
                setError(error as? ImageRepresentableError)
            }
            
            stopExecution()
        }
    }
    
    private func adjustBrightness(for representable: ImageRepresentable, with level: Float) async {
        do {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                imageState = .loading
            }
            
            let newImage = try await Adjustment.applyBrightnessAdjustment(for: representable.image, with: level)
            let newRepresentable = ImageRepresentable(
                from: newImage,
                applyedFilter: representable.applyedFilter,
                applyedAdjustments: .brightness,
                levelOfAdjustment: adjustmentLevel
            )
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.representable = newRepresentable
                imageState = .success
            }
        } catch {
            setError(error)
        }
    }
}
