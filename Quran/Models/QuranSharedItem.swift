//
//  Quran.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit


public let apiRootUrl = URL(string:"https://api.quran.com/api/v4")
public let audioDownloadRootUrl = URL(string: "https://verses.quran.com")
public let recitationId: Int = 7 //TODO: Need to load all reciters
public let languageCode: String = "bn"
let rtlIsolate = "\u{202A}"

class QuranSharedItem {

    
    private static var isInitialized: Bool = false
    private static var _shared:QuranSharedItem!
    
    private var chapters: [Chapter]? = nil
    private var languages: [Language] = []
    private var translationInfos: [TranslationInfo] = []
    private var languageSpecificTranslationInfo: [Language: [TranslationInfo]] = [:]
    
    static func getSharedItem() async throws -> QuranSharedItem {
        if self.isInitialized{
            return _shared
        } else {
            _shared = try await QuranSharedItem()
            return _shared
        }
    }
    
    static func getSharedItem(completion: @escaping ((QuranSharedItem?) -> ())){
        if self.isInitialized{
            completion(_shared)
        } else {
            Task{
                let sharedItem = try? await getSharedItem()
                DispatchQueue.main.async {
                    completion(sharedItem)
                }
            }
        }
    }
    
    
    private init() async throws{
        try await self.loadLanguages()
        try await self.loadTranslationsInfo()
        try await self.loadChapters()
    }
    
    private func loadTranslationsInfo() async throws{
        guard let url = apiRootUrl?.appending(path: "resources").appending(path: "translations") else {
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Root: Decodable{
            let translations: [TranslationInfo]
        }
        do{
            self.translationInfos = try JSONDecoder().decode(Root.self, from: data).translations
        } catch{
            print("Error")
        }

        
        func getLanguage(for name: String) -> Language?{
            for language in self.languages{
                if language.name?.lowercased() == name{
                    return language
                }
            }
            return nil
        }
        
        for info in self.translationInfos{
            if let languageName = info.language_name?.lowercased(),
               let language = getLanguage(for: languageName){
                if self.languageSpecificTranslationInfo[language] == nil{
                    self.languageSpecificTranslationInfo[language] = []
                }
                self.languageSpecificTranslationInfo[language]!.append(info)
            }
        }
    }
    
    private func loadLanguages() async throws{
        guard let url = apiRootUrl?.appending(path: "resources").appending(path: "languages") else {
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Root: Decodable{
            let languages: [Language]
        }
        self.languages = try JSONDecoder().decode(Root.self, from: data).languages
    }
    
    private func loadChapters() async throws{
        guard var url = apiRootUrl?.appending(path: "chapters") else {
            return
        }
        url = url.appending(queryItems: [URLQueryItem(name: "language", value: languageCode)])

        let (data, _) = try await URLSession.shared.data(from: url)
        struct Root: Decodable{
            let chapters: [Chapter]
        }
        self.chapters = try JSONDecoder().decode(Root.self, from: data).chapters
    }
}

extension QuranSharedItem{
    func chapterCount() -> Int{
        return chapters?.count ?? 0
    }
    
    func getChapter(for idx: Int) -> Chapter?{
        return chapters?[idx]
    }
    
    func getLanguages() -> [Language]?{
        return self.languages
    }
    
    func getTranslationInfos() -> [Language: [TranslationInfo]]{
        return self.languageSpecificTranslationInfo
    }
    
    func getLanguage(fromIso iso: String) -> Language?{
        for language in self.languages{
            if language.iso_code == iso{
                return language
            }
        }
        return nil
    }
}
