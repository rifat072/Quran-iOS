//
//  Verse.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class Verse: Decodable {

    let id: Int
    let chapter_id: Int?
    let verse_number: Int
    let verse_key: String
    let verse_index: Int?
    let text_uthmani: String?
    let text_uthmani_simple: String?
    let text_imlaei: String?
    let text_imlaei_simple: String?
    let text_indopak: String?
    let text_uthmani_tajweed: String?
    let juz_number: Int
    let hizb_number: Int
    let rub_number: Int?
    let sajdah_type: Int?
    let sajdah_number: Int?
    let page_number: Int
    let image_url: URL?
    let image_width: Int?
    var words: [Word]?{
        didSet{
            words?.sort(by: { word1, word2 in
                word1.position < word2.position
            })
        }
    }

}
