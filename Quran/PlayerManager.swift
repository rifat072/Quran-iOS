//
//  PlayerManager.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import AVFoundation
import MediaPlayer
import UIKit
import FloatingPanel

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


class PlayerManager: NSObject {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    static let shared = PlayerManager()
    
    private var currentlyPlayingIndex: Int? = nil
    private var playList: [Verse] = []
    private let player: AVQueuePlayer  = AVQueuePlayer()
    private var isPlaying: Bool = false
    private var repeationType: RepeationType = ._1
    private var currentLoopCount: Int = 1
    weak var navigationController: UINavigationController? = nil
    private let floatingPanel: FloatingPanelController = FloatingPanelController()
    private let floatingPanelContentVC: FloatingPanelContentVC

    
    private override init(){
        self.floatingPanelContentVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "FloatingPanelContentVC") as! FloatingPanelContentVC
        self.repeationType = ._1
        super.init()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerItemDidFinishPlaying(sender:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: .main) { time in
            self.floatingPanelContentVC.setTotalDuration(value: Float(self.player.currentItem?.duration.seconds ?? 0 ))
            
            self.floatingPanelContentVC.currentProgress(value: Float(time.seconds))
        }
 
        self.setupRemoteTransportControls()
    }
    
    private func showFloatingPanel(){
        if self.navigationController?.visibleViewController != self.floatingPanel{
            self.navigationController?.visibleViewController?.present(self.floatingPanel, animated: true)
        }
    }
    
    private func dismisFloatingPanel(){
        if self.navigationController?.visibleViewController == self.floatingPanel{
            self.floatingPanel.dismiss(animated: true)
        }
    }
    
    func configureFloatingPanel(navControl: UINavigationController){
        self.floatingPanel.delegate = self
        self.floatingPanelContentVC.delgate = self
        self.floatingPanel.set(contentViewController: self.floatingPanelContentVC)
        self.floatingPanel.isRemovalInteractionEnabled = true
        self.floatingPanel.contentMode = .fitToBounds
        self.floatingPanel.layout = MyFloatingPanelLayout()
        self.navigationController = navControl
    }
    
    
    private func makePlayerActive(){
        self.player.play()
        self.isPlaying = true
        if self.currentlyPlayingIndex == nil{
            self.currentlyPlayingIndex = 0
        }
    }
    
    private func makePlayerDeactive(){
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
        self.showFloatingPanel()
        self.floatingPanelContentVC.playerPlay()
        self.makePlayerActive()
    }
    func pause(){
        self.floatingPanelContentVC.playerStopped()
        self.makePlayerDeactive()
    }
    
    func setRepationType(type: RepeationType){
        self.repeationType = type
        self.currentLoopCount = 1
    }
    
    func addVerseToPlayList(verse: Verse){
        let playerItem = VersePlayerItem(verse: verse)
        self.player.insert(playerItem, after: nil)
        self.playList.append(verse)
    }
    
    func clearPlayList(){
        self.player.removeAllItems()
        self.playList = []
        self.currentLoopCount = 1
    }
    
    func getPlayListCount() -> Int{
        return self.playList.count
    }
}

extension PlayerManager: FloatingPanelContentVCDelegate{
    func prevBtnPressed() {
        //TODO: Need to Implement
    }
    
    func playButtonPressed() {
        self.togglePlayPause()
    }
    
    func nextButtonPressed() {
        //TODO: Need to Implement
    }
    
    func progressSliderChanged(value: Float) {
        //TODO: Need to Implement
    }
}

extension PlayerManager: FloatingPanelControllerDelegate{

    func floatingPanelDidChangeState(_ fpc: FloatingPanelController){
        print("Called \(#function)")
    }

    func floatingPanelWillRemove(_ fpc: FloatingPanelController){
        print("Called \(#function)")
    }

    /// Called when a panel is removed from the parent view controller.
    func floatingPanelDidRemove(_ fpc: FloatingPanelController){
        self.pause()
        self.clearPlayList()
    }

}



extension PlayerManager{
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying(title: String, currentTime: CGFloat, duraion: Float, rate: Float) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duraion
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension PlayerManager{
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &VersePlayerItem.playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status){
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber{
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            if status == .readyToPlay{
                QuranSharedItem.getSharedItem { [weak self] quran in
                    guard let self = self,
                          let quran = quran,
                          let playerItem = self.player.currentItem as? VersePlayerItem else {
                        return
                    }
                    
                    let verse_key = playerItem.verse.verse_key.split(separator: ":")
                    let duration = playerItem.duration.seconds
                    let currenTime = playerItem.currentTime().seconds
                    let rate = self.player.rate
                    let rtlIsolate = "\u{202A}"
                    if let chapter = quran.getChapter(for: Int(verse_key[0])! - 1){
                        let title = "\(rtlIsolate)\(chapter.name_arabic ?? "") | \(chapter.name_complex ?? "") | \(chapter.translated_name.name) | Ayah - \(verse_key[1] )"
                        
                        DispatchQueue.main.async {
                            self.setupNowPlaying(title: title, currentTime: currenTime, duraion: Float(duration), rate: rate)
                            self.floatingPanelContentVC.setTitle(title: title)
                        }

                    }
                    
                }

            }
        }

        
    }


    
    @objc private func playerItemDidFinishPlaying(sender: Notification){
        if self.currentlyPlayingIndex! + 1 == self.playList.count{
            self.currentlyPlayingIndex = 0
            self.player.removeAllItems()
            
            func addVerses(){
                for verse in self.playList{
                    let playerItem = VersePlayerItem(verse: verse)
                    self.player.insert(playerItem, after: nil)
                }
            }
            
            
            if self.repeationType == ._1{
                self.clearPlayList()
                self.dismisFloatingPanel()
            } else if self.repeationType == ._infinite{
                addVerses()
            } else {
                self.currentLoopCount += 1
                let loopCount = self.repeationType.getIntValue()
                if self.currentLoopCount <= loopCount{
                    addVerses()
                } else {
                    self.clearPlayList()
                    self.dismisFloatingPanel()
                }
            }
 
        } else {
            self.currentlyPlayingIndex! += 1
            self.currentlyPlayingIndex! %= self.playList.count
        }
        
    }
}
