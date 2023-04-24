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
                                self.setupNowPlaying(title: title, currentTime: currenTime, duraion: Float(duration), rate: rate)
                                self.floatingPanelContentVC.setTitle(title: title)
                                if let verse = (self.player.currentItem as? VersePlayerItem)?.verse{
                                    self.floatingPanelContentVC.setVerse(verse: verse)
                                    self.continousReadingDelegate?.setVerse(verse: verse)
                                }

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
    
    @MainActor private func dismisFloatingPanel(){
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
        if player.currentItem == nil{
            Task(priority: .high) {
                self.prevStatus = .unknown
                if let versePlayerItem = await self.playList?.getNextVersePlayerItem(){
                    self.player.replaceCurrentItem(with: versePlayerItem)
                    await self.showFloatingPanel()
                    await self.floatingPanelContentVC.playerPlay()
                    self.makePlayerActive()
                } else {
                    self.player.replaceCurrentItem(with: nil)
                    await self.dismisFloatingPanel()
                    await self.floatingPanelContentVC.playerStopped()
                    self.makePlayerDeactive()
                }
                
            }
        } else {
            self.makePlayerActive()
        }

    }
    func pause(){
        self.floatingPanelContentVC.playerStopped()
        self.makePlayerDeactive()
    }
    
    func setPlayList(playList: PlayList?){
        self.pause()
        self.player.replaceCurrentItem(with: nil)
        self.playList = playList
    }
    
}

extension PlayerManager: FloatingPanelContentVCDelegate{

    
    func playButtonPressed() {
        self.togglePlayPause()
    }
    
    func prevBtnPressed() {
        Task(priority: .high) {
            self.prevStatus = .unknown
            if let versePlayerItem = await self.playList?.prevPressed(){
                self.player.replaceCurrentItem(with: versePlayerItem)
                self.play()
            } else {
                self.player.replaceCurrentItem(with: nil)
                await self.dismisFloatingPanel()
            }
        }
    }
    
    func nextButtonPressed() {
        Task(priority: .high) {
            self.prevStatus = .unknown
            if let versePlayerItem = await self.playList?.nextPressed(){
                self.player.replaceCurrentItem(with: versePlayerItem)
                self.play()
            } else {
                self.player.replaceCurrentItem(with: nil)
                await self.dismisFloatingPanel()
            }
        }
    }
    
    func progressSliderChanged(value: Float) {
        self.pause()
        self.player.seek(to: CMTime(seconds: Double(value), preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { bool in
            
        }
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
            self.prevStatus = .unknown
            if let versePlayerItem = await self.playList?.getNextVersePlayerItem(){
                self.player.replaceCurrentItem(with: versePlayerItem)
            } else {
                self.player.replaceCurrentItem(with: nil)
                await self.dismisFloatingPanel()
            }
        }
    }
}
