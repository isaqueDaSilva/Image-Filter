//
//  AdjustmentSliderControl.swift
//  Image Filter
//
//  Created by Isaque da Silva on 1/28/26.
//

import SwiftUI

struct AdjustmentSliderControl: View {
    @Binding var value: Float
    let selectedAdjustment: Adjustment
    var confirmAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent {
                Text(value, format: .number)
                    .bold()
            } label: {
                Text(selectedAdjustment.rawValue)
                    .bold()
            }
            
            Slider(
                value: $value,
                in: selectedAdjustment.rangeValue,
                step: 0.1
            ) {
                Text(selectedAdjustment.rawValue)
            } minimumValueLabel: {
                Text(selectedAdjustment.rangeValue.lowerBound, format: .number)
            } maximumValueLabel: {
                Text(selectedAdjustment.rangeValue.upperBound, format: .number)
            }
            .padding(.bottom)
            
            Button {
                confirmAction()
            } label: {
                Text("Confirm")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
