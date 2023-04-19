//
//  Chapter.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class ChapterInfo: Decodable
{
    let chapter_id: Int
    let text: String
    let short_text: String
    let language_name: String?
    let source: String
}

class Chapter: Decodable {
    
    enum VerseParseError: Error {
        case outOfIndex
    }
    
    
    private let id: Int?
    private let revelation_place: String?
    private let revelation_order: Int?
    private let bismillah_pre: Bool?
    let name_complex: String?
    let name_arabic: String?
    private let verses_count: Int?
    private let pages: [Int]?
    let translated_name: TranslatedName
    
    private var chapterInfo: ChapterInfo?
    private var verses: [Verse?]
    
    enum CodingKeys: CodingKey {
        case id
        case revelation_place
        case revelation_order
        case bismillah_pre
        case name_complex
        case name_arabic
        case verses_count
        case pages
        case translated_name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.revelation_place = try container.decodeIfPresent(String.self, forKey: .revelation_place)
        self.revelation_order = try container.decodeIfPresent(Int.self, forKey: .revelation_order)
        self.bismillah_pre = try container.decodeIfPresent(Bool.self, forKey: .bismillah_pre)
        self.name_complex = try container.decodeIfPresent(String.self, forKey: .name_complex)
        self.name_arabic = try container.decodeIfPresent(String.self, forKey: .name_arabic)
        self.verses_count = try container.decodeIfPresent(Int.self, forKey: .verses_count)
        self.pages = try container.decodeIfPresent([Int].self, forKey: .pages)
        self.translated_name = try container.decode(TranslatedName.self, forKey: .translated_name)
        self.chapterInfo = nil
        if let verses_count = self.verses_count{
            self.verses = [Verse?](repeating: nil, count: verses_count + 1)
        } else {
            self.verses = []
        }
        
    }
    
}
extension Chapter{
    
    func getVersesCount() -> Int{
        return self.verses_count ?? 0
    }
    
    func getInfo() async throws -> ChapterInfo?{
        if let chapterInfo = self.chapterInfo {
            return chapterInfo
        }
        guard let id = self.id,
              let url = apiRootUrl?.appending(path: "chapters").appending(path: "\(id)").appending(path: "info") else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Root: Decodable{
            let chapter_info: ChapterInfo?
        }
        self.chapterInfo = try JSONDecoder().decode(Root.self, from: data).chapter_info
        return self.chapterInfo
    }
    
    func loadVerse(idx: Int) async throws -> Verse?{
        guard let verses_count = self.verses_count else {
            return nil
        }
        if(idx < 1 || idx > verses_count){
            throw VerseParseError.outOfIndex
        }
        
        if let verse = self.verses[idx] {
            return verse
        }
        
        guard let id = self.id,
              var url = apiRootUrl?.appending(path: "verses").appending(path: "by_key").appending(path: "\(id):\(idx)") else {
            return nil
        }
        
        url = url.appending(queryItems: [URLQueryItem(name: "words", value: "true"),
                                        URLQueryItem(name: "word_fields", value: "text_uthmani,text_indopak")])
        
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Root: Decodable{
            let verse: Verse?
        }
        self.verses[idx] = try JSONDecoder().decode(Root.self, from: data).verse
        return self.verses[idx]
    }
}