import Foundation

enum APIConfig {
    static let baseURL = "https://labs.bible.org/api"
    
    static let supportedVersions = [
        "NET": "New English Translation",  // This is the main supported version
        "AAVE": "African American Vernacular English"  // This comes from local JSON
    ]
}

enum APIEndpoint {
    case getVerse(book: String, chapter: Int, verse: Int, version: String)
    case getChapter(book: String, chapter: Int, version: String)
    
    var url: URL? {
        switch self {
        case .getVerse(let book, let chapter, let verse, let version):
            let passage = "\(book) \(chapter):\(verse)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "\(APIConfig.baseURL)/?passage=\(passage)&type=json&formatting=plain&version=\(version)")
            
        case .getChapter(let book, let chapter, let version):
            let passage = "\(book) \(chapter)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "\(APIConfig.baseURL)/?passage=\(passage)&type=json&formatting=plain&version=\(version)")
        }
    }
}

