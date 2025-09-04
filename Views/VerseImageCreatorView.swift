//
//  VerseImageCreatorView.swift
//  AAVE Bible Concordance
//

import SwiftUI
import PhotosUI

struct VerseImageCreatorView: View {
    let verse: Verse
    @Environment(\.dismiss) private var dismiss

    @State private var fontSize: CGFloat = 24
    @State private var referenceFontSize: CGFloat = 16
    @State private var textColor: Color = .white
    @State private var textAlignment: TextAlignment = .center
    @State private var textPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.width / 2.5)
    @State private var userImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingShareSheet = false
    @State private var finalImage: UIImage?
    @GestureState private var magnifyBy = CGFloat(1.0)
    @State private var showingFontPicker = false
    @State private var selectedFont = "CormorantGaramond-Regular"
    @State private var showScrollHint = false

    @State private var isBold = false
    @State private var isItalic = false

    private let watermark = "@officialaavebibleapp"
    
    // Available fonts
    private let availableFonts = [
        "CormorantGaramond-Regular",
        "CormorantGaramond-Bold",
        "CormorantGaramond-Italic",
        "CormorantGaramond-BoldItalic",
        "Avenir-Book",
        "Avenir-Heavy",
        "Georgia",
        "Georgia-Bold",
        "Helvetica",
        "Helvetica-Bold"
    ]

    var dynamicFont: String {
        // Don't override font selection with bold/italic when font picker is showing
        if showingFontPicker {
            return selectedFont
        } else {
            // Apply bold/italic styling to the selected font
            if let baseFontName = selectedFont.split(separator: "-").first {
                let base = String(baseFontName)
                
                switch (isBold, isItalic) {
                case (true, true):
                    return "\(base)-BoldItalic"
                case (true, false):
                    return "\(base)-Bold"
                case (false, true):
                    return "\(base)-Italic"
                default:
                    // If no styling, use the selected font as is
                    return selectedFont
                }
            } else {
                // Fallback to default font family with styling
                switch (isBold, isItalic) {
                case (true, true): return "CormorantGaramond-BoldItalic"
                case (true, false): return "CormorantGaramond-Bold"
                case (false, true): return "CormorantGaramond-Italic"
                default: return "CormorantGaramond-Regular"
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Text("Create Verse Image").font(.headline)
                Spacer()
                Button("Share") {
                    generateFinalImage()
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .padding()
            .background(Color(.systemBackground))

            // Canvas
            ZStack {
                backgroundView()
                verseTextView()
                referenceTextView()
                watermarkView()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width) // 1:1 square ratio
            .background(Color.black)
            .clipped()

            // Controls - Fixed scrolling issue with proper content width
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    // Existing buttons remain unchanged
                    Button(action: { showingImagePicker = true }) {
                        controlIcon("photo", label: "Background")
                    }
                    
                    Button(action: { showingFontPicker.toggle() }) {
                        controlIcon("textformat", label: "Font")
                    }
                    
                    Button(action: {
                        isBold.toggle()
                        // Don't close font picker when toggling bold
                    }) {
                        VStack {
                            Image(systemName: isBold ? "bold.circle.fill" : "bold.circle")
                                .font(.system(size: 20))
                            Text("Bold").font(.caption)
                        }
                    }
                    
                    Button(action: {
                        isItalic.toggle()
                        // Don't close font picker when toggling italic
                    }) {
                        VStack {
                            Image(systemName: isItalic ? "italic.circle.fill" : "italic.circle")
                                .font(.system(size: 20))
                            Text("Italic").font(.caption)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button { fontSize = max(12, fontSize - 1) } label: { Image(systemName: "arrow.down") }
                            Text("\(Int(fontSize))").frame(width: 25)
                            Button { fontSize = min(72, fontSize + 1) } label: { Image(systemName: "arrow.up") }
                        }
                        Text("Size").font(.caption)
                    }
                    
                    VStack {
                        HStack {
                            Button { referenceFontSize = max(10, referenceFontSize - 1) } label: { Image(systemName: "arrow.down") }
                            Text("\(Int(referenceFontSize))").frame(width: 25)
                            Button { referenceFontSize = min(40, referenceFontSize + 1) } label: { Image(systemName: "arrow.up") }
                        }
                        Text("Ref Size").font(.caption)
                    }
                    
                    Menu {
                        Button("White") { textColor = .white }
                        Button("Black") { textColor = .black }
                        Button("Red") { textColor = .red }
                        Button("Blue") { textColor = .blue }
                        Button("Yellow") { textColor = .yellow }
                        Button("Green") { textColor = .green }
                        Button("Orange") { textColor = .orange }
                        Button("Purple") { textColor = .purple }
                    } label: {
                        controlIcon("paintpalette", label: "Color")
                    }
                    
                    Menu {
                        Button("Left") { textAlignment = .leading }
                        Button("Center") { textAlignment = .center }
                        Button("Right") { textAlignment = .trailing }
                    } label: {
                        controlIcon("text.alignleft", label: "Align")
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // Replace the minWidth with a fixed width calculation based on button count
                .frame(width: UIScreen.main.bounds.width * 2.0) // Adjust multiplier as needed
            }
            .padding(.vertical, 5)
            .background(Color(.systemGray6))
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $userImage)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = finalImage {
                ShareSheet(items: [image])
            }
        }
        .overlay {
            if showingFontPicker {
                fontPickerOverlay()
            }
        }
        .overlay(
            // First-time scroll hint
            VStack {
                Spacer()
                if showScrollHint {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Scroll across for more options")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                            
                            Image(systemName: "arrow.down")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding(.top, 4)
                                .scaleEffect(showScrollHint ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showScrollHint)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                        .transition(.opacity)
                    }
                }
            }
            .allowsHitTesting(false)
        )
        .onAppear {
            checkForScrollHint()
        }
    }

    private func fontPickerOverlay() -> some View {
        VStack {
            HStack {
                Text("Select Font")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    showingFontPicker = false
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(availableFonts, id: \.self) { font in
                        Button(action: {
                            selectedFont = font
                        }) {
                            HStack {
                                Text(font.replacingOccurrences(of: "-", with: " "))
                                    .font(.custom(font, size: 18))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedFont == font {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(selectedFont == font ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 400)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private func backgroundView() -> some View {
        Group {
            if let image = userImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()
            } else {
                Image("verse_template_default")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()
            }
        }
    }

    private func verseTextView() -> some View {
        Text(verse.text)
            .font(.custom(dynamicFont, size: fontSize * magnifyBy))
            .foregroundColor(textColor)
            .multilineTextAlignment(textAlignment)
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .position(textPosition)
            .gesture(
                DragGesture().onChanged { value in
                    self.textPosition = value.location
                }
            )
            .gesture(
                MagnificationGesture()
                    .updating($magnifyBy) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { value in
                        self.fontSize = min(72, self.fontSize * value)
                        self.referenceFontSize = min(40, self.referenceFontSize * value)
                    }
            )
    }

    private func referenceTextView() -> some View {
        Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
            .font(.custom(dynamicFont, size: referenceFontSize))
            .foregroundColor(textColor.opacity(0.8))
            .position(x: textPosition.x, y: textPosition.y + 100)
    }

    private func watermarkView() -> some View {
        Text(watermark)
            .font(.footnote)
            .foregroundColor(.white.opacity(0.7))
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.width - 20)
    }

    private func controlIcon(_ name: String, label: String) -> some View {
        VStack {
            Image(systemName: name)
                .font(.system(size: 20))
            Text(label).font(.caption)
        }
    }

    private func generateFinalImage() {
        let squareSize = UIScreen.main.bounds.width
        
        let renderer = ImageRenderer(content:
            ZStack {
                backgroundView()
                VStack(spacing: 12) {
                    Text(verse.text)
                        .font(.custom(dynamicFont, size: fontSize))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(textAlignment)
                        .padding(.horizontal, 20)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: squareSize * 0.85)
                    
                    Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                        .font(.custom(dynamicFont, size: referenceFontSize))
                        .foregroundColor(textColor.opacity(0.8))
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    Text(watermark)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: squareSize, height: squareSize) // 1:1 square ratio
        )
        
        if let uiImage = renderer.uiImage {
            finalImage = uiImage
            showingShareSheet = true
        }
    }
    
    private func checkForScrollHint() {
        let hasSeenScrollHint = UserDefaults.standard.bool(forKey: "hasSeenVerseImageScrollHint")
        if !hasSeenScrollHint {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showScrollHint = true
                }
                
                // Hide after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showScrollHint = false
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenVerseImageScrollHint")
                }
            }
        }
    }
}

// Image picker using UIKit
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}



#Preview {
    VerseImageCreatorView(verse: Verse(
        text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
        translation: "AAVE",
        reference: VerseReference(book: "John", chapter: 3, verse: 16)
    ))
}
