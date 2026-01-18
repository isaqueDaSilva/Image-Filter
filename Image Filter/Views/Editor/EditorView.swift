//
//  EditorView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import PhotosUI
import SwiftUI

struct EditorView: View {
    @State private var viewModel = ViewModel()
    @State private var photoLibraryHandler = PhotoLibraryHandler()
    @State private var isSavingPhotoAlert = false
    @State private var isShowingCleanCacheAlert = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let heightSize = proxy.size.height
                let widthSize = proxy.size.width
                
                let frame = ((heightSize > widthSize) ? widthSize : heightSize)
                let layout = heightSize > widthSize ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
                
                layout {
                    ImageView(
                        imageState: viewModel.imageState,
                        image: viewModel.selectedImage?.swiftuiImage
                    )
                    .frame(width: frame, height: frame)
                    
                    if viewModel.imageState == .empty {
                        PhotoPickerButton(
                            imageSelection: $viewModel.imageSelection,
                            isDisabled: photoLibraryHandler.readWriteAuthorizationStatus != .authorized
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .bottomBar) {
                        FilterPickerMenu {
                            viewModel.applyNegativeFilter()
                        }
                        .disabled(viewModel.cache.isEmpty)
                    }
                    #elseif os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        FilterPickerMenu {
                            viewModel.applyNegativeFilter()
                        }
                        .disabled(viewModel.cache.isEmpty)
                    }
                    #endif
                    
                    ToolbarItem(placement: .confirmationAction) {
                        SaveButton {
                            if viewModel.cache.count > 1 {
                                isSavingPhotoAlert = true
                            }
                        }
                        .disabled(viewModel.cache.count <= 1)
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .destructive) {
                            isShowingCleanCacheAlert = true
                        } label: {
                            Text("Clean Photo")
                        }
                        .disabled(viewModel.cache.isEmpty)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Button {
                                viewModel.previousImage()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .disabled(viewModel.cache.isEmpty || viewModel.cache.first == viewModel.selectedImage)
                            
                            Button {
                                viewModel.nextImage()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(viewModel.cache.isEmpty || viewModel.cache.last == viewModel.selectedImage)
                        }
                    }
                }
                .alert("Save Photo", isPresented: $isSavingPhotoAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Save") {
                        if let selectedImage = viewModel.selectedImage {
                            photoLibraryHandler.saveImage(selectedImage)
                            viewModel.emptyCache()
                        }
                    }
                } message: {
                    Text("This action will be save the image in your photo library.")
                }
                .alert("Clean Photo", isPresented: $isShowingCleanCacheAlert) {
                    Button("Clean", role: .destructive) {
                        viewModel.emptyCache()
                    }
                } message: {
                    Text("When you confirm this action, you won't be able to return at the current state.")
                }
            }
            .padding()
            .task {
                await photoLibraryHandler.checkAuthorizationStatus()
            }
        }
    }
}

#Preview {
    EditorView()
}
