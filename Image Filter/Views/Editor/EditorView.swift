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
                    
                    if viewModel.isShowingBrightnessSlider {
                        VStack {
                            Slider(
                                value: $viewModel.sliderValue,
                                in: 0.1...3.0,
                                step: 0.1) {
                                    Text("Brightness")
                                } minimumValueLabel: {
                                    Text("0.1")
                                } maximumValueLabel: {
                                    Text("3.0")
                                } onEditingChanged: { isChanged in
                                    if isChanged {
                                        viewModel.adjustBrightness()
                                    }
                                }
                            
                            Text("\(viewModel.sliderValue)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .bottomBar) {
                        FilterPickerMenu {
                            viewModel.applyNegativeFilter()
                        } brightnessAdjustment: {
                            viewModel.showBrightnessSlider()
                        }
                        .disabled(viewModel.cache.isEmpty)
                    }
                    #elseif os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        FilterPickerMenu {
                            viewModel.applyNegativeFilter()
                        } brightnessAdjustment: {
                            viewModel.showBrightnessSlider()
                        }
                        .disabled(viewModel.cache.isEmpty)
                    }
                    #endif
                    
                    ToolbarItem(placement: .confirmationAction) {
                        SaveButton {
                            if viewModel.cache.count > 1 {
                                viewModel.showAlert(.savePhoto)
                            }
                        }
                        .disabled(viewModel.cache.count <= 1)
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
                .alert(viewModel.error?.title ?? "", isPresented: $viewModel.isShowingError) { } message: {
                    Text(viewModel.error?.description ?? "")
                }
                .alert(viewModel.alert?.title ?? "", isPresented: $viewModel.isShowingAlert) {
                    Button("Cancel", role: .cancel) { }
                    
                    if let alert = viewModel.alert {
                        AlertButton(alert: alert) {
                            switch alert {
                            case .savePhoto:
                                if let selectedImage = viewModel.selectedImage {
                                    photoLibraryHandler.saveImage(selectedImage)
                                    viewModel.emptyCache()
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
