//
//  ChapterButton.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/9/25.
//

import SwiftUI

struct ChapterButton: View {
    let chapter: Int
    let isDownloaded: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(AAVEColors.accent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AAVEColors.accent, lineWidth: 1)
                )
            
            VStack {
                Text("\(chapter)")
                    .font(AAVETypography.chapterNumber)
                if !isDownloaded {
                    Image(systemName: "icloud.and.arrow.down")
                        .font(AAVETypography.caption)
                }
            }
            .foregroundColor(.primary)
            .padding(8)
        }
        .frame(height: 60)
    }
}

#Preview {
    HStack {
        ChapterButton(chapter: 1, isDownloaded: true)
        ChapterButton(chapter: 2, isDownloaded: false)
    }
    .padding()
}
