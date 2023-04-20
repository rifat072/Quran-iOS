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

protocol PlayerManagerDelegate: NSObject{
    func updateDuration(value: Float)
    func currentPlayerProgress(value: Float)
}


class PlayerManager: NSObject {
    //TODO: Need to maintain Queue for downloading But downloading is fast enough
    static let shared = PlayerManager()
    
    private var currentlyPlayingIndex: Int?
    private var playList: [Verse]
    private let player: AVQueuePlayer
    private let shouldLoop: Bool
    private var timer: Timer?
    private var isPlaying: Bool
    private var playerItemContext = 0
    
    weak var navigationController: UINavigationController? = nil
    private let floatingPanel: FloatingPanelController
    private let floatingPanelContentVC: FloatingPanelContentVC
    
    
    weak var delegate: PlayerManagerDelegate? = nil
    
    private override init(){
        self.currentlyPlayingIndex = nil
        self.playList = []
        self.player = AVQueuePlayer()
        self.shouldLoop = false
        self.timer = nil
        self.isPlaying = false
        self.floatingPanel = FloatingPanelController()
        self.floatingPanelContentVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "FloatingPanelContentVC") as! FloatingPanelContentVC
        
        super.init()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerItemDidFinishPlaying(sender:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: .main) { time in
            self.floatingPanelContentVC.setTotalDuration(value: Float(self.player.currentItem?.duration.seconds ?? 0 ))
            self.delegate?.currentPlayerProgress(value: Float(time.seconds))
            
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
        self.showFloatingPanel()
        self.floatingPanelContentVC.playerPlay()
        self.makePlayerActive()
    }
    func pause(){
        self.floatingPanelContentVC.playerStopped()
        self.makePlayerDeactive()
    }
    
    func addVerseToPlayList(verse: Verse){
        let playerItem = VersePlayerItem(verse: verse)
        self.player.insert(playerItem, after: nil)
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
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Movie"
        
        if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension PlayerManager{

    
    @objc private func playerItemDidFinishPlaying(sender: Notification){
        if self.currentlyPlayingIndex! + 1 == self.playList.count{
            self.player.removeAllItems()
            for verse in self.playList{
                let playerItem = VersePlayerItem(verse: verse)
                self.player.insert(playerItem, after: nil)
            }
        } else {
            self.currentlyPlayingIndex! += 1
        }
        
    }
}
