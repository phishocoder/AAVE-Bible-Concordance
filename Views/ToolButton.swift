//
//  ToolButton.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import SwiftUI

struct ToolButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    var isActive: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(AAVETypography.toolIcon)
                    .foregroundColor(isActive ? AAVEColors.accent : .primary)
                Text(label)
                    .font(AAVETypography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(AAVEColors.surface)
            .cornerRadius(8)
        }
    }
}
