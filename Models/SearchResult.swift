//
//  SearchResult.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let reference: VerseReference
    let aaveText: String
    let traditionalText: String
    
    var text: String {
        aaveText
    }
    
    init(book: String, chapter: Int, verse: Int, aaveText: String, traditionalText: String) {
        self.reference = VerseReference(book: book, chapter: chapter, verse: verse)
        self.aaveText = aaveText
        self.traditionalText = traditionalText
    }
}
