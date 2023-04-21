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

class QuranSharedItem {

    
    private static var isInitialized: Bool = false
    private static var _shared:QuranSharedItem!
    
    private var chapters: [Chapter]? = nil
    private var languages: [Language]? = nil
    
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
                completion(sharedItem)
            }
        }
    }
    
    
    private init() async throws{
        try await self.loadLanguages()
        try await self.loadChapters()
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
        guard let url = apiRootUrl?.appending(path: "chapters") else {
            return
        }

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
}
