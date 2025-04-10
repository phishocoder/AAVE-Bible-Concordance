//
//  RedVerseText.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/1/25.
//

import SwiftUI

struct RedVerseText: UIViewRepresentable {
    var verse: String
    
    // Add a coordinator to handle size changes
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: RedVerseText
        
        init(_ parent: RedVerseText) {
            self.parent = parent
        }
    }

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        
        // Configure the label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .natural
        label.allowsDefaultTighteningForTruncation = false
        
        // Ensure the label can be sized properly
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // Always add debug logging for the verse text
        print("VERSE-DEBUG - RedVerseText component created")
        print("VERSE-DEBUG - Text length: \(verse.count)")
        print("VERSE-DEBUG - Contains <red>: \(verse.contains("<red>"))")
        print("VERSE-DEBUG - Contains </red>: \(verse.contains("</red>"))")
        
        // Process the text and apply the attributed string
        let attributedText = TextParser.debugParseVerseTextNS(verse)
        
        // Always debug the attributed string
        print("VERSE-DEBUG - Attributed string length: \(attributedText.length)")
        let range = NSRange(location: 0, length: attributedText.length)
        var foundColorAttributes = false
        attributedText.enumerateAttributes(in: range, options: []) { (attrs, range, _) in
            if let color = attrs[.foregroundColor] as? UIColor {
                foundColorAttributes = true
                print("VERSE-DEBUG - Found color attribute at range: \(range), color: \(color == .red ? "RED" : "OTHER")")
            }
        }
        
        if !foundColorAttributes {
            print("VERSE-DEBUG - NO color attributes found in the entire string")
        }
        
        label.attributedText = attributedText
        
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        // Update the attributed text when the view updates
        let attributedText = TextParser.debugParseVerseTextNS(verse)
        uiView.attributedText = attributedText
    }
}

// Alternative SwiftUI implementation
struct RedVerseTextSwiftUI: View {
    var verse: String
    
    var body: some View {
        // Add debug print
        let _ = print("SWIFTUI-DEBUG - RedVerseTextSwiftUI created with text: \(verse.prefix(30))...")
        let _ = print("SWIFTUI-DEBUG - Contains <red>: \(verse.contains("<red>"))")
        
        // Use the debug parser to get the attributed string
        let attributedText = TextParser.debugParseVerseTextNS(verse)
        let swiftUIAttributedText = TextParser.convertToAttributedString(attributedText)
        
        return Text(swiftUIAttributedText)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}
