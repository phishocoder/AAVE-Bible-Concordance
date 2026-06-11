import Foundation

struct ScriptureQueryExpander {
    private static let stopWords: Set<String> = [
        "about", "Bible", "does", "feel", "find", "for", "from", "help", "me", "say",
        "scripture", "scriptures", "talk", "teach", "the", "verses", "what", "when", "where"
    ].map { $0.lowercased() }.reduce(into: Set<String>()) { $0.insert($1) }

    private static let concepts: [String: [String]] = [
        "anger": ["anger", "angry", "wrath", "gentle"],
        "anxious": ["anxious", "anxiety", "worry", "peace", "fear"],
        "children": ["children", "child", "teach", "wisdom"],
        "decision": ["decision", "wisdom", "understanding", "guidance"],
        "fear": ["fear", "afraid", "courage", "peace", "trust"],
        "forgiveness": ["forgive", "forgiveness", "mercy", "grace"],
        "forgive": ["forgive", "forgiveness", "mercy", "grace"],
        "hope": ["hope", "comfort", "strength", "endure"],
        "humility": ["humble", "humility", "pride", "serve"],
        "justice": ["justice", "righteous", "fair", "poor"],
        "lonely": ["alone", "lonely", "comfort", "presence"],
        "loss": ["grief", "mourning", "comfort", "hope"],
        "love": ["love", "charity", "kind", "neighbor"],
        "marriage": ["marriage", "husband", "wife", "faithful"],
        "money": ["money", "wealth", "rich", "treasure", "content"],
        "patience": ["patient", "patience", "endure", "wait"],
        "poor": ["poor", "needy", "generous", "give"],
        "pride": ["pride", "proud", "humble", "humility"],
        "suffering": ["suffer", "suffering", "trial", "endure", "hope"],
        "temptation": ["temptation", "tempted", "resist", "escape"],
        "thankful": ["thanks", "thankful", "gratitude", "praise"],
        "trust": ["trust", "faith", "believe", "hope"],
        "welcoming": ["stranger", "welcome", "hospitality", "neighbor"],
        "wisdom": ["wisdom", "wise", "understanding", "knowledge"],
        "words": ["words", "tongue", "speak", "speech"]
    ]

    static func searchTerms(for query: String, limit: Int = 10) -> [String] {
        let words = normalizedWords(in: query)
        var terms: [String] = []
        var seen = Set<String>()

        func append(_ term: String) {
            guard terms.count < limit, seen.insert(term).inserted else { return }
            terms.append(term)
        }

        for word in words {
            for expansion in concepts[word] ?? [] {
                append(expansion)
            }
        }

        for word in words where word.count >= 3 && !stopWords.contains(word) {
            append(word)
        }

        return terms
    }

    private static func normalizedWords(in value: String) -> [String] {
        value
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" })
            .map(String.init)
    }
}
