//
//  CardView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/27/26.
//


import SwiftUI

struct CardView<Item: Identifiable & Equatable>: View {
    @Binding var selectedItem: Item
    let title: String
    let item: Item
    
    var body: some View {
        Text(title)
            .frame(width: 100, height: 100)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedItem == item ? .blue : .secondary, lineWidth: 2, antialiased: true)
                    .foregroundStyle(.secondary)
            }
    }
}