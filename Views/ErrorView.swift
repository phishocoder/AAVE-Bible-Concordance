//
//  ErrorView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct ErrorView: View {
    let error: BibleError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
            }
        }
        .padding()
    }
}

#Preview {
    ErrorView(error: .networkError) {
        print("Retry tapped")
    }
}
