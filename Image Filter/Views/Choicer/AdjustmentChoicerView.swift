//
//  AdjustmentChoicerView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/25/26.
//

import SwiftUI

struct AdjustmentChoicerView: View {
    var filterAction: (Filter) -> Void
    var adjustmentAction: (Adjustment) -> Void
    
    @State private var selectedFilter: Filter = .none
    @State private var selectedAdjustment: Adjustment = .none
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Filter.allCases, id: \.id) { filter in
                    CardView(
                        selectedItem: $selectedFilter,
                        title: filter.rawValue,
                        item: filter
                    )
                    .onTapGesture {
                        selectedFilter = filter
                        filterAction(filter)
                    }
                }
                
                Divider()
                
                ForEach(Adjustment.allCases, id: \.id) { adjustment in
                    CardView(
                        selectedItem: $selectedAdjustment,
                        title: adjustment.rawValue,
                        item: adjustment
                    )
                    .onTapGesture {
                        selectedAdjustment = adjustment
                        
                    }
                }
            }
        }
    }
}





#Preview {
    AdjustmentChoicerView { _ in } adjustmentAction: { _ in }
}
