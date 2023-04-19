//
//  PlayerManager.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import AVFoundation

protocol PlayerManagerDelegate: NSObject{
    func updateDuration(value: Float)
    func currentPlayerProgress(normalizedValue: Float)
}

class PlayerManager: NSObject {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    
    private var currentlyPlayingIndex: Int?
    private var playList: [Verse]
    private let player: AVPlayer
    private let shouldLoop: Bool
    private var timer: Timer?
    private var isPlaying: Bool
    private var playerItemContext = 0
    
    weak var delegate: PlayerManagerDelegate? = nil

    override init(){
        self.currentlyPlayingIndex = nil
        self.playList = []
        self.player = AVPlayer()
        self.shouldLoop = false
        self.timer = nil
        self.isPlaying = false
        super.init()
        
        
        AudioDownloaderOperation.isPresentInPlayList = self.isPresentInPlayList(verse:)
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.playerItemDidFinishPlaying(sender:)),
          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: nil)
    }
    
    @objc private func timerSelector(timer: Timer){
        let currentTime = self.player.currentTime().seconds
        if let totaltime = self.player.currentItem?.duration.seconds{
            self.delegate?.currentPlayerProgress(normalizedValue: Float(currentTime/totaltime))
        }
    }
    
    func isPresentInPlayList(verse: Verse) -> Bool{
        return playList.firstIndex(of: verse) != nil
    }
    
    private func makePlayerActive(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerSelector(timer:)), userInfo: nil, repeats: true)
        self.player.play()
        self.isPlaying = true
    }
    
    private func makePlayerDeactive(){
        self.timer?.invalidate()
        self.timer = nil
        self.isPlaying = false
        self.player.pause()
    }
    
    func togglePlayPause(){
        if self.isPlaying{
            self.pause()
        } else {
            self.play()
        }
    }
    
    func play(){
        if self.currentlyPlayingIndex == nil && self.playList.count >= 1{
            self.currentlyPlayingIndex = 0
            self.play(index: self.currentlyPlayingIndex!)
        } else {
            self.makePlayerActive()
        }
    }
    func pause(){
        self.makePlayerDeactive()
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
        AudioDownloaderOperation.addDownloadIfNeeded(verse: verse) { [weak self] in
            guard let self = self else {
                return
            }
            let url = verse.getSavedUrl()!
            let playerItem = AVPlayerItem(url: url)
            self.player.replaceCurrentItem(with: playerItem)
            
            playerItem.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                   options: [.old, .new],
                                   context: &playerItemContext)
            
            self.makePlayerActive()
            


        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            if status == .readyToPlay{
                if let totaltime = self.player.currentItem?.duration.seconds{
                    self.delegate?.updateDuration(value: Float(totaltime))
                }
            }
        }
    }
    
    @objc private func playerItemDidFinishPlaying(sender: Notification){
        if self.currentlyPlayingIndex == nil{
            self.isPlaying = false
            return
        }
        self.currentlyPlayingIndex! += 1
        if self.currentlyPlayingIndex! >= self.playList.count{
            if shouldLoop{
                self.currentlyPlayingIndex = 0
                self.play(index: self.currentlyPlayingIndex!)
            } else {
                self.currentlyPlayingIndex = nil
                self.isPlaying = false
            }
        }
        if self.currentlyPlayingIndex != nil{
            self.play(index: self.currentlyPlayingIndex!)
        }
        

    }
}
