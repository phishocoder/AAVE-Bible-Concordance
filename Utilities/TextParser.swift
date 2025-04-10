//
//  TextParser.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/1/25.
//

import SwiftUI

// MARK: - NSRange Extension to Support Optional Logic
extension NSRange {
    func toOptional() -> NSRange? {
        return self.location != NSNotFound ? self : nil
    }
}

// MARK: - TextParser for Rendering Styled Verses
struct TextParser {
    
    /// Parses verse text and returns an AttributedString with Jesus's words in red (SwiftUI compatible)
    static func parseVerseText(_ text: String) -> AttributedString {
        let openTag = "<red>"
        let closeTag = "</red>"
        
        // Create a mutable string to work with
        var workingText = text
        var attributedString = AttributedString(text)
        
        // Find all occurrences of the tags and process them
        while let openTagRange = workingText.range(of: openTag),
              let closeTagRange = workingText.range(of: closeTag, range: openTagRange.upperBound..<workingText.endIndex) {
            
            // Get the text between tags that needs to be colored
            let startIndex = workingText.index(openTagRange.upperBound, offsetBy: 0)
            let endIndex = closeTagRange.lowerBound
            let textToColor = String(workingText[startIndex..<endIndex])
            
            // Remove the tags from the working text
            let beforeOpenTag = String(workingText[..<openTagRange.lowerBound])
            let afterCloseTag = String(workingText[closeTagRange.upperBound...])
            workingText = beforeOpenTag + textToColor + afterCloseTag
            
            // Create a new attributed string with the updated text
            attributedString = AttributedString(workingText)
            
            // Calculate the range in the new string to apply attributes
            let redTextStartIndex = beforeOpenTag.count
            let redTextLength = textToColor.count
            
            // Apply attributes to the range
            if let range = Range<AttributedString.Index>(
                NSRange(location: redTextStartIndex, length: redTextLength),
                in: attributedString
            ) {
                attributedString[range].foregroundColor = .red
                attributedString[range].font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            }
        }
        
        return attributedString
    }
    
    // Test function should be at the struct level, not inside another function
    static func testRedTextParsing() {
        let testVerse = "But Jesus said, <red>Let it happen for now. We gotta do this to fulfill what's right in God's eyes.</red> So John was like, \"Bet,\" and baptized Him."
        print("TEST - Original verse: \(testVerse)")
        print("TEST - Contains <red>: \(testVerse.contains("<red>"))")
        print("TEST - Contains </red>: \(testVerse.contains("</red>"))")
        
        let result = debugParseVerseTextNS(testVerse)
        print("TEST - Result string: \(result.string)")
        
        // Check at position 16 (inside the red text) instead of 15
        print("TEST - Result has attributes: \(result.attributes(at: 16, effectiveRange: nil).count > 0)")
        
        // Additional checks to verify attributes
        if let color = result.attributes(at: 16, effectiveRange: nil)[.foregroundColor] as? UIColor {
            print("TEST - Text color at position 16: \(color == .red ? "RED" : "NOT RED")")
        } else {
            print("TEST - No color attribute found at position 16")
        }
    }
    
    // Debug version that returns NSAttributedString for testing
    static func debugParseVerseTextNS(_ text: String) -> NSAttributedString {
        let openTag = "<red>"
        let closeTag = "</red>"
        
        print("PARSER-DEBUG - Input text: \(text.prefix(50))...")
        print("PARSER-DEBUG - Contains <red>: \(text.contains(openTag))")
        print("PARSER-DEBUG - Contains </red>: \(text.contains(closeTag))")
        
        // If no tags, just return plain text
        if !text.contains(openTag) || !text.contains(closeTag) {
            print("PARSER-DEBUG - No tags found, returning plain text")
            return NSAttributedString(string: text)
        }
        
        // Create a new string without tags to work with
        var processedText = text
        var redRanges: [(start: Int, length: Int)] = []
        
        // Find all tag pairs and their positions
        var searchStartIndex = processedText.startIndex
        while let openRange = processedText.range(of: openTag, range: searchStartIndex..<processedText.endIndex) {
            let contentStartIndex = openRange.upperBound
            
            guard let closeRange = processedText.range(of: closeTag, range: contentStartIndex..<processedText.endIndex) else {
                print("PARSER-DEBUG - Found opening tag but no closing tag")
                break
            }
            
            let contentEndIndex = closeRange.lowerBound
            
            // Calculate positions for the attributed string
            let startPosition = processedText.distance(from: processedText.startIndex, to: openRange.lowerBound)
            let contentLength = processedText.distance(from: contentStartIndex, to: contentEndIndex)
            
            print("PARSER-DEBUG - Found red text at position \(startPosition) with length \(contentLength)")
            
            // Store the range that will need to be colored red
            redRanges.append((start: startPosition, length: contentLength))
            
            // Remove the close tag first (working backwards)
            processedText.removeSubrange(closeRange)
            
            // Then remove the open tag (position is still valid)
            processedText.removeSubrange(openRange)
            
            // Update search position for next iteration
            searchStartIndex = openRange.lowerBound
        }
        
        // Create the attributed string with the processed text
        let attributedString = NSMutableAttributedString(string: processedText)
        
        // Apply red color to all the ranges we found
        // We need to adjust each range based on the tags we've removed
        var tagPairsRemoved = 0
        for (start, length) in redRanges {
            // Adjust for removed tags: each pair of tags is 11 characters (<red></red>)
            let adjustedStart = start - (tagPairsRemoved * openTag.count)
            
            // Apply the attributes
            let range = NSRange(location: adjustedStart, length: length)
            attributedString.addAttribute(.foregroundColor, value: UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) : UIColor.red
            }, range: range)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: range)
            
            print("PARSER-DEBUG - Applied red color at adjusted position \(adjustedStart) with length \(length)")
            
            tagPairsRemoved += 1
        }
        
        return attributedString
    }
    
    // Helper method to convert NSAttributedString to AttributedString
    static func convertToAttributedString(_ nsAttributedString: NSAttributedString) -> AttributedString {
        do {
            return try AttributedString(nsAttributedString, including: \.uiKit)
        } catch {
            print("Error converting NSAttributedString to AttributedString: \(error)")
            return AttributedString(nsAttributedString.string)
        }
    }
    
    // Alternative implementation using NSAttributedString internally
    static func parseVerseTextAlternative(_ text: String) -> AttributedString {
        let nsAttributedString = debugParseVerseTextNS(text)
        return convertToAttributedString(nsAttributedString)
    }
}
