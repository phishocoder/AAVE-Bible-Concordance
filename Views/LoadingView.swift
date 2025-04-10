//
//  LoadingView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LoadingView(message: "Loading data...")
}
