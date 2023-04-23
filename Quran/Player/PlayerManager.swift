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

protocol ContinouseReadingDelegate: NSObject{
    func currentProgress(value: Float)
    func setTotalDuration(value: Float)
    func setVerse(verse: Verse)
}


class PlayerManager: NSObject {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    static let shared = PlayerManager()
    
    private var playList: PlayList? = nil
    private let player: AVQueuePlayer  = AVQueuePlayer()
    private var isPlaying: Bool = false
    weak var navigationController: UINavigationController? = nil
    private let floatingPanel: FloatingPanelController = FloatingPanelController()
    private let floatingPanelContentVC: FloatingPanelContentVC
    weak var continousReadingDelegate: ContinouseReadingDelegate? = nil

    
    private var prevStatus: AVPlayerItem.Status? = .unknown
    private override init(){
        self.floatingPanelContentVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "FloatingPanelContentVC") as! FloatingPanelContentVC
        super.init()
        
        self.registerNotifications()
        self.addPeriodicObserver()
        self.setupRemoteTransportControls()
    }
    
    private func registerNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerItemDidFinishPlaying(sender:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)
    }
    
    private func addPeriodicObserver(){
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: .main) { time in
            if self.player.currentItem?.status == .readyToPlay{
                self.floatingPanelContentVC.currentProgress(value: Float(time.seconds))
                self.continousReadingDelegate?.currentProgress(value: Float(time.seconds))
                if self.prevStatus != .readyToPlay{
                    self.floatingPanelContentVC.setTotalDuration(value: Float(self.player.currentItem?.duration.seconds ?? 0 ))
                    self.continousReadingDelegate?.setTotalDuration(value: Float(self.player.currentItem?.duration.seconds ?? 0 ))
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
                        
                        if let chapter = quran.getChapter(for: Int(verse_key[0])! - 1){
                            let title = "\(rtlIsolate)\(chapter.name_arabic ?? "") | \(chapter.name_complex ?? "") | \(chapter.translated_name.name) | Ayah - \(verse_key[1] )"
                            
                            func updateUI(){
//                                self.setupNowPlaying(title: title, currentTime: currenTime, duraion: Float(duration), rate: rate)
//                                self.floatingPanelContentVC.setTitle(title: title)
//                                self.floatingPanelContentVC.setVerse(verse: self.playList[self.currentlyPlayingIndex!])
//
//                                self.continousReadingDelegate?.setVerse(verse: self.playList[self.currentlyPlayingIndex!])
                            }
                            if Thread.isMainThread{
                                updateUI()
                            } else {
                                DispatchQueue.main.async {
                                    updateUI()
                                }
                            }
                        }
                    }
                }
            }
            self.prevStatus = self.player.currentItem?.status
        }
    }
    
    @MainActor private func showFloatingPanel(){
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
        self.floatingPanel.surfaceView.backgroundColor = .clear
        self.floatingPanel.view.backgroundColor = .clear
        
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
        Task(priority: .high) {
            let versePlayerItem = await self.playList?.getNextVersePlayerItem()
            self.player.replaceCurrentItem(with: versePlayerItem)
            self.prevStatus = .unknown
            
            await self.showFloatingPanel()
            await self.floatingPanelContentVC.playerPlay()
            self.makePlayerActive()
        }
    }
    func pause(){
        self.floatingPanelContentVC.playerStopped()
        self.makePlayerDeactive()
    }
    
    func setPlayList(playList: PlayList?){
        self.pause()
        self.playList = playList
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
        self.playList = nil
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

    @objc private func playerItemDidFinishPlaying(sender: Notification){
        
        Task(priority: .high) {
            let versePlayerItem = await self.playList?.getNextVersePlayerItem()
            self.player.replaceCurrentItem(with: versePlayerItem)
            self.prevStatus = .unknown
        }
        
    }
}
