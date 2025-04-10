//
//  TestamentPicker.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct TestamentPicker: View {
    @Binding var selectedTestament: Testament?
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    selectedTestament = .old
                }
            } label: {
                Text("Old Testament")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(selectedTestament == .old ? Color.accentColor : Color.clear)
                    .foregroundColor(selectedTestament == .old ? .white : .primary)
                    .cornerRadius(8)
            }
            
            Button {
                withAnimation {
                    selectedTestament = .new
                }
            } label: {
                Text("New Testament")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(selectedTestament == .new ? Color.accentColor : Color.clear)
                    .foregroundColor(selectedTestament == .new ? .white : .primary)
                    .cornerRadius(8)
            }
            
            Button {
                withAnimation {
                    selectedTestament = nil
                }
            } label: {
                Text("All")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(selectedTestament == nil ? Color.accentColor : Color.clear)
                    .foregroundColor(selectedTestament == nil ? .white : .primary)
                    .cornerRadius(8)
            }
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
