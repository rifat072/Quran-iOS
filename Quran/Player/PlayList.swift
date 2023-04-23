//
//  PlayList.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 23/4/23.
//

import UIKit


class PlayList: NSObject {
    
//    private actor VerseMap{
//        private var verses: [Int: Verse] = [:]
//        private var _versesCount: Int = 0
//
//
//        var count: Int{
//            return self._versesCount
//        }
//
//        func addVerse(verse: Verse){
//            let id = Int(verse.verse_key.split(separator: ":")[1])! - 1
//            verses[id] = verse
//            _versesCount += 1
//        }
//
//        func isLoaded(index: Int) -> Bool{
//            return verses[index] != nil
//        }
//    }
    
    private static let ADVANCE_LOADING_COUNT = 5
    private let chapter: Chapter
    private let fromAyah: Int
    private let toAyah: Int
    private var totalCount: Int{
        return (toAyah - fromAyah) + 1
    }
    
    private var currentIndex: Int{
        didSet{
//            self.checkIfLoadingNeeded()
        }
    }
    
//    private var verseMap: VerseMap = VerseMap()

    private var verses: [Verse] = []{
        didSet{
//            if let completion = self.completionsToCall{
//                if currentIndex < verses.count{
//                    self.sendVerse()
//                }
//            }
        }
    }
//    private var completionsToCall: ((Verse) -> ())? = nil
    
    
    init(chapter: Chapter, from: Int? = nil, to: Int? = nil, repeatationType: RepeationType = ._1){
        self.chapter = chapter
        self.fromAyah = from ?? 1
        self.toAyah = to ?? chapter.getVersesCount()
        self.currentIndex = 0

        super.init()
    }
    
    
    func getNextVersePlayerItem() async -> VersePlayerItem {
        let verse = try! await chapter.loadVerse(idx: currentIndex)
        currentIndex += 1
        return VersePlayerItem(verse: verse!)
    }
    
//    func getNextVerse(completion: @escaping (Verse) -> ()){
//        self.completionsToCall = completion
//        if currentIndex < verses.count{
//            self.sendVerse()
//        }
//    }
    
//    private func sendVerse(){
//        completionsToCall?(self.verses[currentIndex])
//        self.completionsToCall = nil
//        self.currentIndex += 1
//        //TODO:
//        self.currentIndex %= totalCount
//    }
//

    
//    private func checkIfLoadingNeeded() async throws{
//        let alreadyLoadedCount = await verseMap.count
//        let advanceLoadingIndex = currentIndex + PlayList.ADVANCE_LOADING_COUNT
//
//        let mini = await verseMap.count
//        let maxi = min(advanceLoadingIndex, totalCount)
//
//        if(mini > maxi) {return}
//
//        await withThrowingTaskGroup(of: Verse.self, body: { group in
//            for i in mini...maxi{
//                group.addTask {
//                    if let verse = try? await self.chapter.loadVerse(idx: i){
//                        await self.verseMap.addVerse(verse: verse)
//                    }
//                }
//            }
//        })
//
//    }
    

}
