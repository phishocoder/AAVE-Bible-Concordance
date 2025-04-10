//
//  TranslationCard.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct TranslationCard: View {
    let title: String
    let text: String
    let fontSize: CGFloat
    var isComingSoon: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if isComingSoon {
                HStack {
                    Image(systemName: "hourglass")
                        .foregroundColor(.orange)
                    Text(text)
                        .font(.system(size: fontSize))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text(text)
                    .font(.system(size: fontSize))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}
