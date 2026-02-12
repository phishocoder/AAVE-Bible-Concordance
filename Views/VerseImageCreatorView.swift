//
//  VerseImageCreatorView.swift
//  AAVE Bible Concordance
//

import SwiftUI
import PhotosUI

struct VerseImageCreatorView: View {
    let verse: Verse
    var onReadInContext: ((VerseReference) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var fontSize: CGFloat = 24
    @State private var referenceFontSize: CGFloat = 16
    @State private var textColor: Color = .white
    @State private var textAlignment: TextAlignment = .center
    @State private var textPositionRatio: CGPoint = CGPoint(x: 0.5, y: 0.45) // normalized, keeps preview/export in sync
    @State private var userImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingShareSheet = false
    @State private var finalImage: UIImage?
    @GestureState private var magnifyBy = CGFloat(1.0)
    @State private var showingFontPicker = false
    @State private var selectedFont = "CormorantGaramond-Regular"
    @State private var showScrollHint = false
    @State private var isRendering = false
    @State private var showRenderError = false
    @State private var renderErrorMessage = ""
    @State private var showShareFollowUp = false

    @State private var isBold = false
    @State private var isItalic = false

    private let watermark = "@officialaavebibleapp"
    private let exportCanvasSize = CGSize(width: 1080, height: 1350) // 4:5 portrait, Instagram-safe

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
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                // Canvas
                VerseImageCanvas(
                    verse: verse,
                    userImage: userImage,
                    fontName: dynamicFont,
                    fontSize: fontSize,
                    referenceFontSize: referenceFontSize,
                    textColor: textColor,
                    textAlignment: textAlignment,
                    textPositionRatio: $textPositionRatio,
                    watermark: watermark,
                    allowsInteraction: true,
                    magnification: magnifyBy
                )
                // The preview renders at the exact export aspect ratio so the renderer uses identical layout.
                .aspectRatio(exportCanvasSize, contentMode: .fit)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .background(Color.black)
                .clipped()
                .overlay(alignment: .topLeading) {
                    hintPill
                }
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

                controlsBar
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $userImage)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = finalImage {
                ShareSheet(items: [image]) { completed in
                    if completed {
                        showShareFollowUp = true
                    }
                }
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
        .alert("Unable to Share", isPresented: $showRenderError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(renderErrorMessage)
        }
        .overlay(alignment: .bottom) {
            if showShareFollowUp {
                shareFollowUpStrip
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var shareFollowUpStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shared. Keep the Word moving.")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            HStack(spacing: 10) {
                Button("Read in context") {
                    showShareFollowUp = false
                    onReadInContext?(verse.reference)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Mark today complete") {
                    ReadingProgressService.shared.markVerseRead(verse.reference)
                    showShareFollowUp = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Label("Cancel", systemImage: "xmark")
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("Verse Image")
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Button {
                generateFinalImage()
            } label: {
                if isRendering {
                    ProgressView()
                } else {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRendering)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(glassBarBackground)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var controlsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Button(action: { showingImagePicker = true }) {
                    controlIcon("photo", label: "Background")
                }

                Button(action: { showingFontPicker.toggle() }) {
                    controlIcon("textformat", label: "Font")
                }

                Button(action: {
                    isBold.toggle()
                }) {
                    controlIcon(isBold ? "bold.circle.fill" : "bold.circle", label: "Bold")
                }

                Button(action: {
                    isItalic.toggle()
                }) {
                    controlIcon(isItalic ? "italic.circle.fill" : "italic.circle", label: "Italic")
                }

                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Button { fontSize = max(12, fontSize - 1) } label: { Image(systemName: "minus.circle") }
                        Text("\(Int(fontSize))").frame(width: 28)
                        Button { fontSize = min(72, fontSize + 1) } label: { Image(systemName: "plus.circle") }
                    }
                    Text("Size").font(.caption)
                }

                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Button { referenceFontSize = max(10, referenceFontSize - 1) } label: { Image(systemName: "minus.circle") }
                        Text("\(Int(referenceFontSize))").frame(width: 28)
                        Button { referenceFontSize = min(40, referenceFontSize + 1) } label: { Image(systemName: "plus.circle") }
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
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(glassBarBackground)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private var glassBarBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 12)
    }

    private var hintPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap")
            Text("Drag to move. Pinch to resize.")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(12)
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
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 12)
    }

    private func controlIcon(_ name: String, label: String) -> some View {
        VStack {
            Image(systemName: name)
                .font(.system(size: 20))
            Text(label).font(.caption)
        }
    }

    private func generateFinalImage() {
        guard !isRendering else { return }
        isRendering = true

        Task { @MainActor in
            defer { isRendering = false }
            guard #available(iOS 16.0, *) else {
                renderErrorMessage = "Sharing requires iOS 16 or later."
                showRenderError = true
                return
            }

            // Render the exact same canvas used for the preview so exported pixels match what the user saw.
            let renderer = ImageRenderer(content:
                VerseImageCanvas(
                    verse: verse,
                    userImage: userImage,
                    fontName: dynamicFont,
                    fontSize: fontSize,
                    referenceFontSize: referenceFontSize,
                    textColor: textColor,
                    textAlignment: textAlignment,
                    textPositionRatio: .constant(textPositionRatio),
                    watermark: watermark,
                    allowsInteraction: false,
                    magnification: 1
                )
                .frame(width: exportCanvasSize.width, height: exportCanvasSize.height)
            )
            // The renderer respects the explicit frame so the bitmap is 1080x1350, safe for most social feeds.
            renderer.proposedSize = ProposedViewSize(exportCanvasSize)
            renderer.scale = UIScreen.main.scale

            if let uiImage = renderer.uiImage {
                finalImage = uiImage
                showingShareSheet = true
                AchievementService.shared.recordShare()
            } else {
                renderErrorMessage = "We couldn't render your image. Try again or simplify the layout."
                showRenderError = true
            }
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

// Shared canvas between preview and export so layout is guaranteed to match pixel-for-pixel.
private struct VerseImageCanvas: View {
    let verse: Verse
    let userImage: UIImage?
    let fontName: String
    let fontSize: CGFloat
    let referenceFontSize: CGFloat
    let textColor: Color
    let textAlignment: TextAlignment
    @Binding var textPositionRatio: CGPoint
    let watermark: String
    let allowsInteraction: Bool
    let magnification: CGFloat
    private let safePaddingRatio: CGFloat = 0.08
    private let referenceOffsetRatio: CGFloat = 0.08
    private let watermarkBottomPaddingRatio: CGFloat = 0.025

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let safeRect = CGRect(
                x: size.width * safePaddingRatio,
                y: size.height * safePaddingRatio,
                width: size.width * (1 - safePaddingRatio * 2),
                height: size.height * (1 - safePaddingRatio * 2)
            )
            let versePosition = CGPoint(
                x: safeRect.minX + textPositionRatio.x * safeRect.width,
                y: safeRect.minY + textPositionRatio.y * safeRect.height
            )

            ZStack {
                // Background always stays behind everything else.
                background(size: size)
                    .overlay(Color.black.opacity(0.18)) // soften busy photos while keeping text above
                    .allowsHitTesting(false)

                VStack(spacing: size.height * referenceOffsetRatio) {
                    Text(verse.text)
                        .font(.custom(fontName, size: fontSize * magnification))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(textAlignment)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.6)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: safeRect.width)

                    Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                        .font(.custom(fontName, size: referenceFontSize))
                        .foregroundColor(textColor.opacity(0.85))
                        .multilineTextAlignment(textAlignment)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.7)
                        .frame(width: safeRect.width)
                }
                .position(versePosition)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("VerseCanvas"))
                        .onChanged { value in
                            guard allowsInteraction else { return }
                            updatePosition(with: value.location, safeRect: safeRect)
                        }
                )
                .zIndex(1) // keep text above any overlays

                Text(watermark)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .position(x: size.width / 2,
                              y: size.height - size.height * watermarkBottomPaddingRatio)
                    .zIndex(1)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
            .background(Color.black)
            .coordinateSpace(name: "VerseCanvas")
        }
    }

    @ViewBuilder
    private func background(size: CGSize) -> some View {
        let base = Group {
            if let image = userImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("verse_template_default")
                    .resizable()
                    .scaledToFill()
            }
        }
        base
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    private func updatePosition(with location: CGPoint, safeRect: CGRect) {
        let normalizedX = ((location.x - safeRect.minX) / safeRect.width).clamped(to: 0...1)
        let normalizedY = ((location.y - safeRect.minY) / safeRect.height).clamped(to: 0...1)
        textPositionRatio = CGPoint(x: normalizedX, y: normalizedY)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
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
