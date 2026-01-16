//
//  SaveButton.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import SwiftUI

struct SaveButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "square.and.arrow.down")
        }
    }
}
