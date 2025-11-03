//
//  TestamentPicker.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct TestamentPicker: View {
    @Binding var selectedTestament: Testament?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            pillButton(title: "Old Testament", isSelected: selectedTestament == .old) {
                withAnimation { selectedTestament = .old }
            }
            pillButton(title: "New Testament", isSelected: selectedTestament == .new) {
                withAnimation { selectedTestament = .new }
            }
            pillButton(title: "All", isSelected: selectedTestament == nil) {
                withAnimation { selectedTestament = nil }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.25), lineWidth: 1)
                )
        )
    }
    
    private func pillButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    Capsule().fill(pillBackground(isSelected: isSelected))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private func pillBackground(isSelected: Bool) -> AnyShapeStyle {
        let gradient = LinearGradient(colors: [Color.accentColor, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        return isSelected ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.clear)
    }
}
