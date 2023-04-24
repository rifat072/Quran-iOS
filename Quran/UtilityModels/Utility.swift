//
//  Utility.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

struct TranslationInfo: Decodable{
    let id: Int?
    let name: String?
    let author_name: String?
    let slug: String?
    let language_name: String?
    let translated_name: TranslatedName?
}

struct TranslatedName: Decodable{
    let name: String
    let language_name: String
}

struct Language: Decodable, Hashable {
    func hash(into hasher: inout Hasher){
        hasher.combine(self.iso_code!)
    }
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso_code! == rhs.iso_code!
    }
    
    let id: Int?
    let name: String?
    let iso_code: String?
    let native_name: String?
    let direction: String?
    let translations_count: Int?
    let translated_name: TranslatedName?
    
}

struct Translation: Decodable{
    let resource_id: Int?
    let resource_name: String?
    let id: Int?
    let text: String?
    let verse_id: Int?
    let language_id: Int?
    let language_name: String?
    let verse_key: String?
    let chapter_id: Int?
    let verse_number: Int?
    let juz_number: Int?
    let hizb_number: Int?
    let rub_number: Int?
    let page_number: Int?
    
    enum CodingKeys: CodingKey {
        case resource_id
        case resource_name
        case id
        case text
        case verse_id
        case language_id
        case language_name
        case verse_key
        case chapter_id
        case verse_number
        case juz_number
        case hizb_number
        case rub_number
        case page_number
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resource_id = try container.decodeIfPresent(Int.self, forKey: .resource_id)
        self.resource_name = try container.decodeIfPresent(String.self, forKey: .resource_name)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)//?.html2String
        self.verse_id = try container.decodeIfPresent(Int.self, forKey: .verse_id)
        self.language_id = try container.decodeIfPresent(Int.self, forKey: .language_id)
        self.language_name = try container.decodeIfPresent(String.self, forKey: .language_name)
        self.verse_key = try container.decodeIfPresent(String.self, forKey: .verse_key)
        self.chapter_id = try container.decodeIfPresent(Int.self, forKey: .chapter_id)
        self.verse_number = try container.decodeIfPresent(Int.self, forKey: .verse_number)
        self.juz_number = try container.decodeIfPresent(Int.self, forKey: .juz_number)
        self.hizb_number = try container.decodeIfPresent(Int.self, forKey: .hizb_number)
        self.rub_number = try container.decodeIfPresent(Int.self, forKey: .rub_number)
        self.page_number = try container.decodeIfPresent(Int.self, forKey: .page_number)
    }

}
struct Transliteration: Decodable{
    let language_name: String?
    let text: String?
}

struct Pagination: Decodable{
    let per_page: Int?
    let current_page: Int?
    let next_page: Int?
    let total_pages: Int?
    let total_records: Int?
}

struct AudioFile: Decodable{
    let url: String?
    let duration: Int?
    let format: String?
    var segments: [[Int]]{
        didSet{
            segments.sort { a, b in
                a[1] < b[1]
            }
        }
    }
}


struct AudioReciterInfo: Decodable{
    let id: Int?
    let name: String?
    let style: TranslatedName?
    let qirat: TranslatedName?
    let translated_name: TranslatedName?
}


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
