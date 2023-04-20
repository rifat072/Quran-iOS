//
//  SurahVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit
import FloatingPanel

class SurahVC: UIViewController {
    
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var chapter: Chapter!
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
    
    
    private var fromSelectionAction: UIAction? = nil
    private var toSelectedAction: UIAction? = nil
    private var repeatSelectionAction: UIAction? = nil
    
    private let playerManager = PlayerManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func playBtnPressed(_ sender: Any) {
        if self.playerManager.getPlayListCount() == 0{
            self.reconfigurePlayList()
        }
        self.playerManager.play()
    }
    
    func reconfigurePlayList(){
        let fromAyah = Int(self.fromSelectionAction?.title ?? "1")!
        var toAyah = Int(self.toSelectedAction?.title ?? "1")!
        toAyah = max(fromAyah, toAyah)
        let repeatationType = RepeationType.getType(str: self.repeatSelectionAction?.title ?? "1")
        self.playerManager.pause()
        
        for i in fromAyah...toAyah{
            if let verse = try! chapter.getVerse(idx: i){
                playerManager.addVerseToPlayList(verse: verse)
            }
        }
        self.playerManager.setRepationType(type: repeatationType)

    }
    
    func invalidatePlayer(){
        self.playerManager.pause()
        self.playerManager.clearPlayList()
    }
}


extension SurahVC: SurahCollectionViewDelegate{
    func isReadyForStream() {
        self.playBtn.isHidden = false
        self.loadDropDownMenus()
    }

    func loadDropDownMenus(){
        let fromActionClosure = {[weak self] (action: UIAction) in
            self?.fromSelectionAction = action
            self?.fromButton.setTitle(self?.fromSelectionAction?.title, for: .normal)
            self?.invalidatePlayer()
        }
        let toActionClosure = {[weak self] (action: UIAction) in
            self?.toSelectedAction = action
            self?.toButton.setTitle(self?.toSelectedAction?.title, for: .normal)
            self?.invalidatePlayer()
        }
        let repeatActionClosure = {[weak self] (action: UIAction) in
            self?.repeatSelectionAction = action
            self?.repeatButton.setTitle(self?.repeatSelectionAction?.title, for: .normal)
            self?.invalidatePlayer()
        }

        
        let verseCount = chapter.getVersesCount()
        
        var fromActions: [UIAction] = []
        var toActions: [UIAction] = []
        var repeationActions: [UIAction] = []
        
        
        for i in 1...verseCount{
            fromActions.append(UIAction(title: "\(i)", handler: fromActionClosure))
            toActions.append(UIAction(title: "\(i)", handler: toActionClosure))
        }
        
        for repeatationType in RepeationType.allCases{
            repeationActions.append(UIAction(title: repeatationType.getString(), handler: repeatActionClosure))
        }
        
        self.fromSelectionAction = fromActions.first
        self.toSelectedAction = toActions.last
        self.repeatSelectionAction = repeationActions.first
        
        fromButton.menu = UIMenu(children: fromActions)
        toButton.menu = UIMenu(children: toActions)
        repeatButton.menu = UIMenu(children: repeationActions)
        
        fromButton.setTitle(fromSelectionAction?.title, for: .normal)
        toButton.setTitle(toSelectedAction?.title, for: .normal)
        repeatButton.setTitle(repeatSelectionAction?.title, for: .normal)
    }
}
