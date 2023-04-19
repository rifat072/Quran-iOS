//
//  VerseDataLoaderOperation.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class AudioDownloaderOperation: Operation {
    

    private static let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    private static let loadingQueue = OperationQueue()
    private static var loadingOperations: [Verse: AudioDownloaderOperation] = [:]
    public static var isPresentInPlayList: ((Verse) -> (Bool))? = nil
    
    public static func addDownloadIfNeeded(verse: Verse, completion: (()->())? = nil){
        semaphore.wait()
        if let dataLoader = loadingOperations[verse]{
            if let completion = completion{
                dataLoader.loadingCompleteHandler = completion
            }
            semaphore.signal()
            return
        }
        if verse.isDownloaded{
            completion?()
        }
        let dataLoader = AudioDownloaderOperation(verse: verse)
        if let completion = completion{
            dataLoader.loadingCompleteHandler = completion
        }
        loadingQueue.addOperation(dataLoader)
        loadingOperations[verse] = dataLoader
        semaphore.signal()
    }
    
    public static func cancelDownload(verse: Verse, shouldForceCancel: Bool = false){
        semaphore.wait()
        let shouldCancel = shouldForceCancel || isPresentInPlayList?(verse) ?? true
        if shouldCancel{
            let loader = loadingOperations[verse]
            loader?.cancel()
            loadingOperations.removeValue(forKey: verse)
        }
        semaphore.signal()
    }
    
    enum State{
        case initialized
        case running
        case finished
        case cancelled
    }
    
    unowned var verse: Verse
    
    var loadingCompleteHandler: (() -> ())? = nil
    var state: State
    
    
    init(verse: Verse) {
        self.verse = verse
        self.state = .initialized
    }
    
    override func main() {
        if isCancelled {
            AudioDownloaderOperation.semaphore.wait()
            AudioDownloaderOperation.loadingOperations.removeValue(forKey: self.verse)
            AudioDownloaderOperation.semaphore.signal()
            self.state = .cancelled
            return
        }
        self.state = .running
        
        Task{
            try await verse.loadAudioFile()
            self.state = .finished
            DispatchQueue.main.async {
                AudioDownloaderOperation.semaphore.wait()
                AudioDownloaderOperation.loadingOperations.removeValue(forKey: self.verse)
                AudioDownloaderOperation.semaphore.signal()
            }
            if isCancelled {
                return
            }
            if let loadingCompleteHandler = loadingCompleteHandler {
                DispatchQueue.main.async {
                    loadingCompleteHandler()
                }
            }
        }

    }
}
