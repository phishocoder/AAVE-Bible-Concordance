//
//  VerseReference.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import Foundation

extension VerseReference {
    var referenceKey: String { "\(book)-\(chapter)-\(verse)" }
    
    static func fromKey(_ key: String) -> VerseReference? {
        let components = key.split(separator: "_")
        guard components.count == 3,
              let chapter = Int(components[1]),
              let verse = Int(components[2]) else {
            return nil
        }
        
        return VerseReference(
            book: String(components[0]),
            chapter: chapter,
            verse: verse,
            timestamp: Date()
        )
    }
}
