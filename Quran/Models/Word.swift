//
//  Word.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class Word: Decodable {
    
    let id: Int?
    let position: Int
    let text_uthmani: String?
    let text_indopak: String?
    let text_imlaei: String?
    let verse_key: String?
    let page_number: Int?
    let line_number: Int?
    let audio_url: URL?
    let location: String?
    let char_type_name: String
    let code_v1: String?
    let translation: Translation
    let transliteration: Transliteration
    
}
