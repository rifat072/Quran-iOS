//
//  SurahVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahVC: UIViewController {
    
    var chapter: Chapter!

    @IBOutlet weak var floatingView: FloatingView!
    
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
    
    private let playerManager = PlayerManager()
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
    
    deinit{
        self.playerManager.pause()
    }
}


extension SurahVC: SurahCollectionViewDelegate{
    func isReadyForStream() {
        self.playBtn.isHidden = false
    }
}

extension SurahVC: PlayerManagerDelegate{
    func currentPlayerProgress(normalizedValue: Float) {
        if normalizedValue.isNaN {
            return
        }
        if floatingView.totalDuration != nil{
            let seconds = Int(normalizedValue * floatingView.totalDuration)
            let dateComponents = DateComponents(second: seconds)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            let formattedString = formatter.string(from: dateComponents)!
            self.floatingView.startTimeLabel.text = formattedString
        }

        self.floatingView.playerSlider.setValue(normalizedValue, animated: true)
    }
    
    func updateDuration(value: Float) {
        self.floatingView.totalDuration = value


    }
    
    
}
