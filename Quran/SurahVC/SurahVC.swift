//
//  SurahVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit
import FloatingPanel

class SurahVC: UIViewController {
    
    var chapter: Chapter!

//    @IBOutlet weak var floatingView: FloatingView!{
//        didSet{
//            self.floatingView.delegate = self
//        }
//    }
    
    @IBOutlet weak var playBtn: UIButton!{
        didSet{
            self.playBtn.isHidden = true
        }
        
    }
    @IBOutlet weak var collectionView: SurahCollectionView!{
        didSet{
            self.collectionView.viewControllerDelegate = self
            self.collectionView.chapter = self.chapter
        }
    }
    
    private let playerManager = PlayerManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerManager.delegate = self
        
    }

    @IBAction func playBtnPressed(_ sender: Any) {
        if self.playerManager.getPlayListCount() == 0{
            for i in 1...chapter.getVersesCount(){
                if let verse = try! chapter.getVerse(idx: i){
                    playerManager.addVerseToPlayList(verse: verse)
                }
            }
        }
        playerManager.togglePlayPause()
    }
}

//extension SurahVC: FloatingViewDelegate{
//    func crossPressed() {
//        self.playerManager.clearPlayList()
//        self.playerManager.pause()
//    }
//}


extension SurahVC: SurahCollectionViewDelegate{
    func isReadyForStream() {
        self.playBtn.isHidden = false
    }
}

extension SurahVC: PlayerManagerDelegate{
    
    func currentPlayerProgress(value: Float) {
//        if value.isNaN {
//            return
//        }
//        if floatingView.totalDuration != nil{
//            let data = secondsToHoursMinutesSeconds(Int(value))
//            let str = NSString(format:"%02d:%02d:%02d", data.0, data.1, data.2)
//            self.floatingView.startTimeLabel.text = String(str)
//            self.floatingView.playerSlider.setValue(value/floatingView.totalDuration!, animated: true)
//        }
    }
    
    func updateDuration(value: Float) {
//        self.floatingView.totalDuration = value
    }
    
    
}
