//
//  PlayerManager.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import AVFoundation

class PlayerManager {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    
    private var currentlyPlayingIndex: Int?
    private var playList: [Verse]
    private let player: AVPlayer
    private let shouldLoop: Bool

    init(){
        self.currentlyPlayingIndex = nil
        self.playList = []
        self.player = AVPlayer()
        self.shouldLoop = false
        
        AudioDownloaderOperation.isPresentInPlayList = self.isPresentInPlayList(verse:)
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.playerItemDidFinishPlaying(sender:)),
          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: nil)
    }
    
    
    func isPresentInPlayList(verse: Verse) -> Bool{
        return playList.firstIndex(of: verse) != nil
    }
    
    
    func play(){
        if self.currentlyPlayingIndex == nil && self.playList.count >= 1{
            self.currentlyPlayingIndex = 0
            self.play(index: self.currentlyPlayingIndex!)
        } else {
            self.player.play()
        }
    }
    func pause(){
        self.player.pause()
    }
    
    func addVerseToPlayList(verse: Verse){
        self.playList.append(verse)
    }
    
    func clearPlayList(){
        self.playList = []
    }
    
    
}

extension PlayerManager{
    private func play(index: Int){
        let verse = self.playList[index]
        AudioDownloaderOperation.addDownloadIfNeeded(verse: verse) {
            let url = verse.getSavedUrl()!
            self.player.replaceCurrentItem(with: AVPlayerItem(url: url))
            self.player.play()
        }
    }
    
    @objc private func playerItemDidFinishPlaying(sender: Notification){
        if self.currentlyPlayingIndex == nil{
            return
        }
        self.currentlyPlayingIndex! += 1
        if self.currentlyPlayingIndex! >= self.playList.count{
            if shouldLoop{
                self.currentlyPlayingIndex = 0
            } else {
                self.currentlyPlayingIndex = nil
            }
        }
        
        self.play(index: self.currentlyPlayingIndex!)

    }
}
