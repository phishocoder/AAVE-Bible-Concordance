//
//  AAVETextView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/18/25.
//

import UIKit

@IBDesignable
class AAVETextView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard UIGraphicsGetCurrentContext() != nil else { return }
        
        let fontSize = min(bounds.width / 4.5, bounds.height * 0.8)
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        
        let text = "AAVE"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // Draw each letter with its color
        drawLetter("A", at: 0, in: textRect, with: font, color: .black, outlineColor: .white)
        drawLetter("A", at: 1, in: textRect, with: font, color: .systemRed)
        drawLetter("V", at: 2, in: textRect, with: font, color: .systemYellow)
        drawLetter("E", at: 3, in: textRect, with: font, color: .systemGreen)
    }
    
    private func drawLetter(_ letter: String, at index: Int, in rect: CGRect, with font: UIFont, color: UIColor, outlineColor: UIColor? = nil) {
        let text = "AAVE"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textWidth = text.size(withAttributes: attributes).width
        
        // Calculate letter position
        let letterWidth = textWidth / CGFloat(text.count)
        let x = rect.origin.x + (letterWidth * CGFloat(index))
        let letterRect = CGRect(x: x, y: rect.origin.y, width: letterWidth, height: rect.height)
        
        // Draw outline if needed
        if let outlineColor = outlineColor {
            let outlineAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: outlineColor,
                .strokeWidth: -3.0,
                .strokeColor: outlineColor
            ]
            letter.draw(in: letterRect, withAttributes: outlineAttributes)
        }
        
        // Draw letter
        let letterAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        letter.draw(in: letterRect, withAttributes: letterAttributes)
    }
}
