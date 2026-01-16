//
//  EditorView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import PhotosUI
import SwiftUI

struct EditorView: View {
    @State private var editorHandler = EditorHandler()
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
                        imageState: editorHandler.imageState,
                        image: editorHandler.selectedImage?.swiftuiImage
                    )
                    .frame(width: frame, height: frame)
                    
                    if editorHandler.imageState == .empty {
                        PhotoPickerButton(
                            imageSelection: $editorHandler.imageSelection,
                            isDisabled: false /*photoLibraryHandler.readWriteAuthorizationStatus != .authorized*/
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .bottomBar) {
                        FilterPickerMenu {
                            editorHandler.applyNegativeFilter()
                        }
                        .disabled(editorHandler.cache.isEmpty)
                    }
                    #elseif os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        FilterPickerMenu {
                            editorHandler.applyNegativeFilter()
                        }
                        .disabled(editorHandler.cache.isEmpty)
                    }
                    #endif
                    
                    ToolbarItem(placement: .confirmationAction) {
                        SaveButton {
                            if editorHandler.cache.count > 1 {
                                isSavingPhotoAlert = true
                            }
                        }
                        .disabled(editorHandler.cache.count <= 1)
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .destructive) {
                            isShowingCleanCacheAlert = true
                        } label: {
                            Text("Clean Photo")
                        }
                        .disabled(editorHandler.cache.isEmpty)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Button {
                                editorHandler.previousImage()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .disabled(editorHandler.cache.isEmpty || editorHandler.cache.first == editorHandler.selectedImage)
                            
                            Button {
                                editorHandler.nextImage()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(editorHandler.cache.isEmpty || editorHandler.cache.last == editorHandler.selectedImage)
                        }
                    }
                }
                .alert("Save Photo", isPresented: $isSavingPhotoAlert) {
                    Button("Cancel") { }
                    Button("Save") {
                        if let selectedImage = editorHandler.selectedImage {
                            photoLibraryHandler.saveImage(selectedImage)
                            editorHandler.emptyCache()
                        }
                    }
                } message: {
                    Text("This action will be save the image in your photo library.")
                }
                .alert("Clean Photo", isPresented: $isShowingCleanCacheAlert) {
                    //Button("Cancel") { }
                    Button("Clean", role: .destructive) {
                        editorHandler.emptyCache()
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
