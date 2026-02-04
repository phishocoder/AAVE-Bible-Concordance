import Foundation

struct ScriptureStore {
    private static func translationService() async -> TranslationService {
        await MainActor.run {
            TranslationService.shared
        }
    }

    static func text(for verseId: String, version: VerseVersion) async -> String? {
        guard let reference = VerseOfDayProvider.reference(forVerseId: verseId) else { return nil }
        do {
            let translationService = await translationService()
            return try await translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: version.rawValue
            )
        } catch {
            return nil
        }
    }

    static func bestText(for verseId: String, preferredVersion: VerseVersion) async -> (text: String, versionUsed: VerseVersion)? {
        let fallbackOrder: [VerseVersion] = {
            var order: [VerseVersion] = []
            order.append(preferredVersion)
            if preferredVersion != .aave { order.append(.aave) }
            if preferredVersion != .net { order.append(.net) }
            for version in VerseVersion.allCases where !order.contains(version) {
                order.append(version)
            }
            return order
        }()

        for version in fallbackOrder {
            if let text = await text(for: verseId, version: version), !text.isEmpty {
                return (text, version)
            }
        }

        return nil
    }
}
