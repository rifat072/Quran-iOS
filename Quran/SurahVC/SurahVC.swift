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
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var collectionView: SurahCollectionView!{
        didSet{
            self.collectionView.chapter = self.chapter
        }
    }
    
    private let playerManager = PlayerManager()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playBtnPressed(_ sender: Any) {
        for i in 1...chapter.getVersesCount(){
            if let verse = try! chapter.getVerse(idx: i){
                playerManager.addVerseToPlayList(verse: verse)
            }
        }
        playerManager.play()
    }
}
