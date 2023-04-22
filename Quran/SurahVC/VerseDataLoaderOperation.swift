//
//  VerseDataLoaderOperation.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class VerseDataLoaderOperation: Operation {
    
    enum State{
        case initialized
        case running
        case finished
        case cancelled
    }
    
    unowned var chapter: Chapter
    let index: Int
    
    var verseViewModel: VerseViewModel? = nil
    var verse: Verse?
    var loadingCompleteHandler: ((VerseViewModel?) -> Void)?
    var state: State
    
    
    init(chapter: Chapter, verseIdx: Int) {
        self.chapter = chapter
        self.index = verseIdx
        self.state = .initialized
    }
    
    override func main() {
        if isCancelled {
            self.state = .cancelled
            return
        }
        self.state = .running
        
        Task{
            let _verse = try await chapter.loadVerse(idx: index)
            if isCancelled {
                self.state = .cancelled
                return
            }
            self.verse = _verse
            self.verseViewModel = VerseViewModel(verse: verse!)
            self.state = .finished
            if let loadingCompleteHandler = loadingCompleteHandler {
                DispatchQueue.main.async { [self] in
                    loadingCompleteHandler(verseViewModel)
                }
            }
        }

    }
}
