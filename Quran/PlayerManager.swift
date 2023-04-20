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
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
        } catch {
            print("Failed to set audio session category.")
        }
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.playerItemDidFinishPlaying(sender:)),
          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: player.currentItem)
    }
    
    @objc private func timerSelector(timer: Timer){
        let currentTime = self.player.currentTime().seconds
        if let totaltime = self.player.currentItem?.duration.seconds{
            self.delegate?.currentPlayerProgress(normalizedValue: Float(currentTime/totaltime))
        }
    }

    private func makePlayerActive(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerSelector(timer:)), userInfo: nil, repeats: true)
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
        self.player.insert(VersePlayerItem(verse: verse), after: nil)
        self.playList.append(verse)
        
    }
    
    func clearPlayList(){
        self.player.removeAllItems()
        self.playList = []
    }
    
    var isFirst = true
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
                self.player.insert(VersePlayerItem(verse: verse), after: nil)
            }
        } else {
            self.currentlyPlayingIndex! += 1
        }

    }
}
