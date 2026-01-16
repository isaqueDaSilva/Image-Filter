//
//  FilterPickerMenu.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/15/26.
//

import SwiftUI

struct FilterPickerMenu: View {
    var negativeFilter: () -> Void
    
    var body: some View {
        Menu {
            Button {
                negativeFilter()
            } label: {
                Text("Negative")
            }
        } label: {
            Image(systemName: "camera.filters")
        }
    }
}
