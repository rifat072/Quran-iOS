//
//  Verse.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit
import AVFoundation

class Verse: Decodable, Hashable {
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        return lhs.verse_key == rhs.verse_key
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(verse_key)
    }


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
    let audio: AudioFile?
    var words: [Word]?{
        didSet{
            words?.sort(by: { word1, word2 in
                word1.position < word2.position
            })
        }
    }
    var translations: [Translation]
    
    
    private static let audioDownloadedDefaults : UserDefaults = UserDefaults(suiteName: "VerseDownload")!
    var isDownloaded: Bool{
        set{
            guard let url = audioDownloadRootUrl?.appending(path: audio?.url ?? "") else {
                return
            }
            Verse.audioDownloadedDefaults.set(newValue, forKey: url.absoluteString)
        } get{
            guard let url = audioDownloadRootUrl?.appending(path: audio?.url ?? "") else {
                return false
            }
            return Verse.audioDownloadedDefaults.bool(forKey: url.absoluteString) 
        }
    }
    
    
    func loadAudioFile() async throws{
        guard let url = audioDownloadRootUrl?.appending(path: audio?.url ?? "") else {
            return
        }

        if let relativePath = audio?.url,
           let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let savedUrl = directory.appending(path:relativePath)
            
            if FileManager.default.fileExists(atPath: savedUrl.path()){
                return
            }
            try? FileManager.default.createDirectory(at: savedUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: savedUrl)
        }
    }
    
    func getSavedUrl() -> URL?{
        if let relativePath = audio?.url,
           let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            return directory.appending(path:relativePath)
        }
        return nil
    }
    
    func getServerURL() -> URL?{
        return audioDownloadRootUrl?.appending(path: audio?.url ?? "")
    }
    
    func getPlayableUrl() -> URL?{
        if self.isDownloaded{
            return self.getSavedUrl()
        } else {
            return self.getServerURL()
        }
    }
    
    func getTranslation(for resourceId: Int) -> Translation?{
        for translation in translations {
            if translation.resource_id == resourceId{
                return translation
            }
        }
        return nil
    }
    

}
