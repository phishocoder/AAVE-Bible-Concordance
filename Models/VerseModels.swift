//
//  VerseModels.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/12/25.
//

import Foundation

struct VerseItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let number: Int
    let text: String
    var reference: VerseReference
    
    static func == (lhs: VerseItem, rhs: VerseItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TranslationPair {
    let aave: String
    let traditional: String
}
