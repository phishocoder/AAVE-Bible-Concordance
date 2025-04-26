//
//  AboutView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("About AAVE Bible")
                    .font(.largeTitle)
                    .bold()
                
                // Main Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("This app provides a study tool for the Bible with culturally relevant translations in AAVE (African American Vernacular English). Our goal is to make biblical study more accessible and engaging for the community.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Disclaimer
                    Text("This content was created in collaboration with AI and guided by cultural insight and spiritual care. Every effort has been made to reflect the original scripture accurately while expressing it through a modern, accessible voice. When in doubt, return to the Word and let the Spirit confirm.")
                        .font(.footnote)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                }
                
                // Features Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "book.fill", text: "Side-by-side AAVE and Traditional translations")
                        FeatureRow(icon: "lightbulb.fill", text: "Cultural commentary and context")
                        FeatureRow(icon: "bookmark.fill", text: "Bookmark favorite verses")
                        FeatureRow(icon: "magnifyingglass", text: "Search across translations")
                    }
                }
                Spacer(minLength: 30)
                
                // Footer
                VStack(spacing: 8) {
                    Divider()
                    Text("Made with 🖤 by PhiSho Apps")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Version 1.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
        }
    }
}

struct IconGuideRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
        }
    }
}

#Preview {
    AboutView()
}
