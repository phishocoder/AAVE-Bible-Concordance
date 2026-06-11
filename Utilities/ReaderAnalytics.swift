import Foundation

enum ReaderAnalyticsEvent {
    case chapterOpened(book: String, chapter: Int, translation: String)
    case verseSelected(reference: VerseReference)
    case commentaryOpened(reference: VerseReference)
    case compareOpened(reference: VerseReference)
    case verseShared(reference: VerseReference)

    var name: String {
        switch self {
        case .chapterOpened: "chapter_opened"
        case .verseSelected: "verse_selected"
        case .commentaryOpened: "commentary_opened"
        case .compareOpened: "compare_opened"
        case .verseShared: "verse_shared"
        }
    }

    var properties: [String: String] {
        switch self {
        case let .chapterOpened(book, chapter, translation):
            return [
                "book": book,
                "chapter": String(chapter),
                "translation": translation
            ]
        case let .verseSelected(reference),
             let .commentaryOpened(reference),
             let .compareOpened(reference),
             let .verseShared(reference):
            return [
                "book": reference.book,
                "chapter": String(reference.chapter),
                "verse": String(reference.verse)
            ]
        }
    }
}

protocol ReaderAnalyticsClient {
    func track(name: String, properties: [String: String])
}

struct NoOpReaderAnalyticsClient: ReaderAnalyticsClient {
    func track(name: String, properties: [String: String]) {}
}

@MainActor
final class ReaderAnalytics {
    static let shared = ReaderAnalytics()

    private var client: any ReaderAnalyticsClient

    init(client: any ReaderAnalyticsClient = NoOpReaderAnalyticsClient()) {
        self.client = client
    }

    func track(_ event: ReaderAnalyticsEvent) {
        client.track(name: event.name, properties: event.properties)
    }

    func setClient(_ client: any ReaderAnalyticsClient) {
        self.client = client
    }
}
