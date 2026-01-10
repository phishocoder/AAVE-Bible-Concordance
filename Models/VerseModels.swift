//
//  VerseModels.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/12/25.
//

import Foundation

struct VerseItem: Identifiable, Equatable, Hashable {
    var id: String { reference.id }
    let number: Int
    let text: String
    var reference: VerseReference
    
    static func == (lhs: VerseItem, rhs: VerseItem) -> Bool {
        lhs.reference.id == rhs.reference.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(reference.id)
    }
}

struct TranslationPair {
    let aave: String
    let traditional: String
}
