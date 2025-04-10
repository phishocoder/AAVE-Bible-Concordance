//
//  CreditsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        List {
            Section(header: Text("Development")) {
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Phil Shobo")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Content")) {
                HStack {
                    Text("AAVE Translation")
                    Spacer()
                    Text("AAVE Bible Project")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("NET Translation")
                    Spacer()
                    Text("NET Bible")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Version")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Credits")
        .listStyle(InsetGroupedListStyle())
    }
}
