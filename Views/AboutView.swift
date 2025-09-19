//// Backup push for version 1.2
//  AboutView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct AboutView: View {
    private let socialPlatforms = SocialPlatform.defaultPlatforms

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About AAVE Bible")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))

                        Text("This app provides a study tool for the Bible with culturally relevant translations in AAVE (African American Vernacular English). Our goal is to make biblical study more accessible and engaging for the community.")
                            .fixedSize(horizontal: false, vertical: true)

                        Text("This content was created in collaboration with AI and guided by cultural insight and spiritual care. Every effort has been made to reflect the original scripture accurately while expressing it through a modern, accessible voice. When in doubt, return to the Word and let the Spirit confirm.")
                            .font(.footnote)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    .glassCard()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.title2)
                            .bold()

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "book.fill", text: "Side-by-side AAVE and Traditional translations")
                            FeatureRow(icon: "lightbulb.fill", text: "Cultural commentary and context")
                            FeatureRow(icon: "bookmark.fill", text: "Bookmark favorite verses")
                            FeatureRow(icon: "magnifyingglass", text: "Search across translations")
                            FeatureRow(icon: "square.and.arrow.up", text: "Share verses and Verse Images")
                            FeatureRow(icon: "bell.fill", text: "Daily Verse Notifications (via Settings → Notifications)")
                        }
                    }
                    .glassCard()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Stay Connected")
                            .font(.title2)
                            .bold()

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(socialPlatforms) { platform in
                                Link(destination: platform.url) {
                                    SocialLinkRow(platform: platform)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .glassCard()

                    VStack(spacing: 8) {
                        Divider()
                            .background(Color.white.opacity(0.3))
                        Text("Made with 🖤 by PhiSho Apps")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("Version 1.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .glassBackground()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 24)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

struct SocialLinkRow: View {
    let platform: SocialPlatform

    var body: some View {
        HStack(spacing: 12) {
            Text(platform.name)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .foregroundStyle(Color.white.opacity(0.6))
        }
    }
}

struct SocialPlatform: Identifiable {
    let name: String
    let url: URL

    var id: String { name }

    static let defaultPlatforms: [SocialPlatform] = [
        SocialPlatform(
            name: "TikTok",
            url: URL(string: "https://www.tiktok.com/@aavebibleapp?_t=ZP-8vcKoQcnPdm&_r=1")!
        ),
        SocialPlatform(
            name: "Instagram",
            url: URL(string: "https://instagram.com/officialaavebibleapp")!
        ),
        SocialPlatform(
            name: "Facebook",
            url: URL(string: "https://www.facebook.com/share/1BXzGezh2H/?mibextid=wwXIfr")!
        ),
        SocialPlatform(
            name: "X (Twitter)",
            url: URL(string: "https://x.com/aavebibleapp?s=21")!
        )
    ]
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
