import Foundation

class BibleAPIService {
    static let shared = BibleAPIService()
    
    private init() {}
    
    func fetchVerse(book: String, chapter: Int, verse: Int, translation: String = "NET") async throws -> Verse {
        let actualTranslation = translation.uppercased()
        
        guard let url = APIEndpoint.getVerse(
            book: book,
            chapter: chapter,
            verse: verse,
            version: actualTranslation
        ).url else {
            throw BibleError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BibleError.networkError
            }
            
            if httpResponse.statusCode != 200 {
                throw BibleError.invalidData
            }
            
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode([BibleAPIResponse].self, from: data)
                guard let verseData = apiResponse.first else {
                    throw BibleError.verseNotFound
                }
                
                let reference = VerseReference(book: book, chapter: chapter, verse: verse)
                return Verse(text: verseData.text, translation: actualTranslation, reference: reference)
            } catch {
                if let text = String(data: data, encoding: .utf8) {
                    let reference = VerseReference(book: book, chapter: chapter, verse: verse)
                    return Verse(text: text, translation: actualTranslation, reference: reference)
                }
                throw BibleError.decodingError
            }
        } catch {
            throw BibleError.networkError
        }
    }
    
    func fetchChapter(book: String, chapter: Int, translation: String = "NET") async throws -> [Verse] {
        let actualTranslation = translation.uppercased()
        
        guard let url = APIEndpoint.getChapter(
            book: book,
            chapter: chapter,
            version: actualTranslation
        ).url else {
            throw BibleError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BibleError.networkError
            }
            
            if httpResponse.statusCode != 200 {
                throw BibleError.invalidData
            }
            
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode([BibleAPIResponse].self, from: data)
                return apiResponse.enumerated().map { index, verseData in
                    let reference = VerseReference(book: book, chapter: chapter, verse: index + 1)
                    return Verse(text: verseData.text, translation: actualTranslation, reference: reference)
                }
            } catch {
                throw BibleError.decodingError
            }
        } catch {
            throw BibleError.networkError
        }
    }
}

struct BibleAPIResponse: Codable {
    let bookname: String
    let chapter: String
    let verse: String
    let text: String
}



