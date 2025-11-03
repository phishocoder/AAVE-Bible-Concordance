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
                    .font(.system(size: 22))
                    .foregroundColor(isActive ? .blue : .primary)
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }
}
