//
//  PlayList.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 23/4/23.
//

import UIKit

enum RepeationType: CaseIterable{
    case _1
    case _2
    case _4
    case _8
    case _infinite
    
    func getString() -> String{
        if self == ._1 {return "1"}
        else if self == ._2{return "2"}
        else if self == ._4{return "4"}
        else if self == ._8{return "8"}
        else {return "infinte"}
    }
    
    static func getType(str: String) -> RepeationType{
        if str == "1" {return ._1}
        else if str == "2"{return ._2}
        else if str == "4"{return ._4}
        else if str == "8"{return ._8}
        else {return ._infinite}
    }
    
    func getIntValue() -> Int{
        if self == ._1{
            return 1
        } else if self == ._2{
            return 2
        } else if self == ._4{
            return 4
        } else if self == ._8{
            return 8
        } else {
            return 100000000
        }
    }
}



class PlayList: NSObject {
    
    private static let ADVANCE_LOADING_COUNT = 5
    private let chapter: Chapter
    private let fromAyah: Int
    private let toAyah: Int
    private let repeationType: RepeationType
    private var totalCount: Int{
        return (toAyah - fromAyah) + 1
    }
    
    private var currentIndex: Int
    private var currentLoopCount: Int

    private var verses: [Verse] = []
    init(chapter: Chapter, from: Int? = nil, to: Int? = nil, repeatationType: RepeationType = ._1){
        self.chapter = chapter
        self.fromAyah = from ?? 1
        self.toAyah = to ?? chapter.getVersesCount()
        self.currentIndex = 0
        self.currentLoopCount = 0
        self.repeationType = repeatationType

        super.init()
    }
    
    
    func getNextVersePlayerItem() async -> VersePlayerItem? {
        if currentIndex >=  totalCount{
            return nil
        }

        let verse = try! await chapter.loadVerse(idx: currentIndex)
        currentIndex += 1
        
        if currentIndex == totalCount{
            self.currentLoopCount += 1
            if self.currentLoopCount < self.repeationType.getIntValue(){
                currentIndex = 0
            }
        }
        
        return VersePlayerItem(verse: verse!)
    }
    
}
