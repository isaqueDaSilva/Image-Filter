//
//  AdjustmentChoicerView.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/25/26.
//

import SwiftUI

struct AdjustmentChoicerView: View {
    @Binding var selectedFilter: Filter?
    @Binding var selectedAdjustment: Adjustment?
    @Binding var adjustmentLevel: Float
    
    var body: some View {
        Group {
            if let selectedAdjustment {
                AdjustmentSliderControl(
                    value: $adjustmentLevel,
                    selectedAdjustment: selectedAdjustment
                ) {
                    withAnimation {
                        self.selectedAdjustment = nil
                    }
                }
            } else {
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
                                withAnimation {
                                    selectedAdjustment = adjustment
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}



#Preview {
    AdjustmentChoicerView(
        selectedFilter: .constant(nil),
        selectedAdjustment: .constant(nil),
        adjustmentLevel: .constant(0)
    )
}
