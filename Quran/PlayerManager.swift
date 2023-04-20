//
//  PlayerManager.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import AVFoundation

protocol PlayerManagerDelegate: NSObject{
    func updateDuration(value: Float)
    func currentPlayerProgress(value: Float)
}

class PlayerManager: NSObject {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    
    private var currentlyPlayingIndex: Int?
    private var playList: [Verse]
    private let player: AVQueuePlayer
    private let shouldLoop: Bool
    private var timer: Timer?
    private var isPlaying: Bool
    private var playerItemContext = 0
    
    weak var delegate: PlayerManagerDelegate? = nil

    override init(){
        self.currentlyPlayingIndex = nil
        self.playList = []
        self.player = AVQueuePlayer()
        self.shouldLoop = false
        self.timer = nil
        self.isPlaying = false
        super.init()
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.playerItemDidFinishPlaying(sender:)),
          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: player.currentItem)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: .main) { time in
            self.delegate?.currentPlayerProgress(value: Float(time.seconds))
        }

    }
    
    private func makePlayerActive(){
        self.player.play()
        self.isPlaying = true
        if self.currentlyPlayingIndex == nil{
            self.currentlyPlayingIndex = 0
        }
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
        self.makePlayerActive()
    }
    func pause(){
        self.makePlayerDeactive()
    }
    
    func addVerseToPlayList(verse: Verse){
        let playerItem = VersePlayerItem(verse: verse)
        self.player.insert(playerItem, after: nil)
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        self.playList.append(verse)
        
    }
    
    func clearPlayList(){
        self.player.removeAllItems()
        self.playList = []
    }
    
    func getPlayListCount() -> Int{
        return self.playList.count
    }
}

extension PlayerManager{

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
        if self.currentlyPlayingIndex! + 1 == self.playList.count{
            self.player.removeAllItems()
            for verse in self.playList{
                let playerItem = VersePlayerItem(verse: verse)
                self.player.insert(playerItem, after: nil)
                playerItem.addObserver(self,
                                       forKeyPath: #keyPath(AVPlayerItem.status),
                                       options: [.old, .new],
                                       context: &playerItemContext)
            }
        } else {
            self.currentlyPlayingIndex! += 1
        }

    }
}
