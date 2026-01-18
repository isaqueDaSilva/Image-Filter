//
//  AlertButton.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/18/26.
//


import PhotosUI
import SwiftUI

struct AlertButton: View {
    let alert: DefaultAlert
    var action: () -> Void
    
    var body: some View {
        switch alert {
        case .savePhoto:
            Button("Save") {
                action()
            }
        case .cleanCache:
            Button("Clean", role: .destructive) {
                action()
            }
        }
    }
}