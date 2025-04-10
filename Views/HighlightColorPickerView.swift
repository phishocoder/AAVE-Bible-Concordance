//
//  HighlightColorPickerView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/20/25.
//

//
//  HighlightColorPickerView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/20/25.
//

import SwiftUI

struct HighlightColorPickerView: View {
    @State private var selectedColor = Color.yellow.opacity(0.3)
    var onColorSelected: (Color) -> Void
    var onRemoveHighlight: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Preview of the highlight
            Text("Sample highlighted text")
                .padding()
                .background(selectedColor)
                .cornerRadius(8)
                .padding(.top)
            
            // Color picker
            ColorPicker("Highlight Color", selection: $selectedColor)
                .padding(.horizontal)
            
            // Apply button
            Button(action: {
                onColorSelected(selectedColor)
            }) {
                Text("Apply Highlight")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Remove highlight button
            Button(action: {
                onRemoveHighlight()
            }) {
                Text("Remove Highlight")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
