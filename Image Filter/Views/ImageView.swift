//
//  ImageView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import SwiftUI

struct ImageView: View {
    let imageState: ImageState
    let image: Image?
    
    var body: some View {
        Group {
            switch imageState {
            case .success:
                if let image {
                    image.resizable()
                }
            case .loading:
                ProgressView()
            case .empty:
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 100))
                    .foregroundColor(.primary)
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
            }
        }
        .scaledToFit()
    }
}
