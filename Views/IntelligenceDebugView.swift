#if DEBUG
import SwiftUI

@MainActor
struct IntelligenceDebugView: View {
    private let service: any IntelligenceService
    private let testReference = VerseReference(book: "John", chapter: 3, verse: 16)

    @State private var guide: StudyGuide?
    @State private var errorMessage: String?
    @State private var isRunning = false

    init() {
        self.service = DefaultIntelligenceService.shared
    }

    init(service: any IntelligenceService) {
        self.service = service
    }

    var body: some View {
        List {
            Section("Availability") {
                LabeledContent("State", value: service.availability.displayName)
                LabeledContent("Test Passage", value: testReference.displayString)
            }

            Section {
                Button {
                    runFallback()
                } label: {
                    if isRunning {
                        ProgressView()
                    } else {
                        Label("Run Deterministic Fallback", systemImage: "play.fill")
                    }
                }
                .disabled(isRunning)
            }

            if let guide {
                Section("Result") {
                    LabeledContent("Execution Source", value: guide.source.rawValue)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bundled Scripture")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(guide.passageText)
                    }

                    if let commentary = guide.commentary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bundled Commentary")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(commentary)
                        }
                    }
                }

                Section("Source References") {
                    ForEach(guide.sourceReferences) { reference in
                        Text(reference.displayString)
                    }
                }

                Section("Related Local Results") {
                    if guide.relatedReferences.isEmpty {
                        Text("No related references found.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(guide.relatedReferences) { reference in
                            Text(reference.displayString)
                        }
                    }
                }
            }

            if let errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Intelligence Debug")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runFallback() {
        isRunning = true
        guide = nil
        errorMessage = nil

        Task {
            do {
                guide = try await service.studyGuide(for: testReference)
            } catch {
                errorMessage = error.localizedDescription
            }
            isRunning = false
        }
    }
}

#Preview {
    NavigationStack {
        IntelligenceDebugView()
    }
}
#endif
