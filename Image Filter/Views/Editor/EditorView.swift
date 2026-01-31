//
//  EditorView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/14/26.
//

import PhotosUI
import SwiftUI
import OrderedCollections

struct EditorView: View {
    @State private var viewModel = ViewModel()
    @State private var photoLibraryHandler = PhotoLibraryHandler()
    
    var body: some View {
        GeometryReader { proxy in
            let staticHeight: CGFloat = 150
            let width = proxy.size.width
            let height = proxy.size.height
            let actualHeight = width > height ? height : (height - staticHeight)
            let layout = height > width ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
            
            layout {
                ImageView(
                    imageState: viewModel.imageState,
                    image: viewModel.representable?.image
                )
                .frame(
                    width: max(0, height > width ? width : height),
                    height: max(0, actualHeight)
                )
                
                Group {
                    if viewModel.imageState == .empty {
                        PhotoPickerButton(
                            imageSelection: $viewModel.imageSelection,
                            isDisabled: photoLibraryHandler.readWriteAuthorizationStatus != .authorized
                        )
                    } else if (viewModel.imageState == .success || viewModel.imageState == .loading) && viewModel.representable != nil {
                        AdjustmentChoicerView(
                            selectedFilter: $viewModel.selectedFilter,
                            selectedAdjustment: $viewModel.selectedAdjustment,
                            adjustmentLevel: $viewModel.adjustmentLevel
                        )
                    }
                }
                #if os(iOS)
                .frame(width: max(0, height > width ? width : height), height: max(0, staticHeight))
                #elseif os(macOS)
                .frame(maxWidth: .infinity)
                .frame(height: staticHeight)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        SaveButton {
                            if !viewModel.cache.isEmpty {
                                viewModel.showAlert(.savePhoto)
                            }
                        }
                        .disabled(
                            viewModel.cache.isEmpty || viewModel.representable?.image == viewModel.cache[viewModel.originalImageKey]?.image
                        )
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .destructive) {
                            if !viewModel.cache.isEmpty {
                                viewModel.showAlert(.cleanCache)
                            }
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
                            .disabled(viewModel.currentImageIndex == 0)
                            
                            Button {
                                viewModel.nextImage()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(viewModel.cache.isEmpty ||  viewModel.currentImageIndex == viewModel.cache.elements.count - 1)
                        }
                    }
                }
                .alert(viewModel.error?.title ?? "", isPresented: $viewModel.isShowingError) { } message: {
                    Text(viewModel.error?.description ?? "")
                }
                .alert(viewModel.alert?.title ?? "", isPresented: $viewModel.isShowingAlert) {
                    Button("Cancel", role: .cancel) { }
                    
                    if let alert = viewModel.alert {
                        AlertButton(alert: alert) {
                            switch alert {
                            case .savePhoto:
                                if let selectedImage = viewModel.representable?.image {
                                    let error = photoLibraryHandler.saveImage(selectedImage)
                                    
                                    if let error {
                                        viewModel.setError(error)
                                    } else {
                                        viewModel.emptyCache()
                                    }
                                }
                            case .cleanCache:
                                viewModel.emptyCache()
                            }
                        }
                    }
                } message: {
                    Text(viewModel.alert?.description ?? "")
                }
            }
        }
        .padding()
        .task {
            await photoLibraryHandler.checkAuthorizationStatus()
        }
    }
}

#Preview {
    EditorView()
}
