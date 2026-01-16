//
//  PhotoPickerButton.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/16/26.
//

import PhotosUI
import SwiftUI

struct PhotoPickerButton: View {
    @Binding var imageSelection: PhotosPickerItem?
    let isDisabled: Bool
    
    var body: some View {
        VStack {
            PhotosPicker(
                "Select a photo.",
                selection: $imageSelection,
                matching: .images
            )
            .buttonStyle(.borderedProminent)
            .padding(.top)
            .disabled(isDisabled)
            
            if isDisabled {
                Text("You need to go to settings app and enable this app get access on your photos library to peform actions.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
    }
}

#Preview {
    PhotoPickerButton(imageSelection: .constant(nil), isDisabled: true)
}
