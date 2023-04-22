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

}
struct Transliteration: Decodable{
    let language_name: String?
    let text: String?
}

class Pagination: Decodable{
    let per_page: Int?
    let current_page: Int?
    let next_page: Int?
    let total_pages: Int?
    let total_records: Int?
}

class AudioFile: Decodable{
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


