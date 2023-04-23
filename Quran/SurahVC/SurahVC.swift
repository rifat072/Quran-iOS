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
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var tableView: SurahTableView!{
        didSet{
            self.tableView.viewControllerDelegate = self
            self.tableView.chapter = self.chapter
        }
    }
    
    private var fromSelectionAction: UIAction? = nil
    private var toSelectedAction: UIAction? = nil
    private var repeatSelectionAction: UIAction? = nil
    
    private let playerManager = PlayerManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = "\(rtlIsolate)\(chapter.name_arabic ?? "") | \(chapter.name_complex ?? "") | \(chapter.translated_name.name)"
        self.titleLabel.text = title
        
        self.loadDropDownMenus()
        
    }

    @IBAction func playBtnPressed(_ sender: Any) {
//        if self.playerManager.getPlayListCount() == 0{
//            self.reconfigurePlayList()
//        }
        self.reconfigurePlayList()
        self.playerManager.play()
    }
    
    func reconfigurePlayList(){
        self.playerManager.pause()
        let fromAyah = Int(self.fromSelectionAction?.title ?? "1")! - 1
        var toAyah = Int(self.toSelectedAction?.title ?? "1")! - 1
        toAyah = max(fromAyah, toAyah)
        let repeatationType = RepeationType.getType(str: self.repeatSelectionAction?.title ?? "1")
        self.playerManager.pause()
        let playList = PlayList(chapter: chapter, from: fromAyah, to: toAyah, repeatationType: repeatationType)
        self.playerManager.setPlayList(playList: playList)

    }
}


extension SurahVC: SurahTableViewDelegate{
    func playButtonPressedFor(verse: Verse) {
        
    }

    func loadDropDownMenus(){
        let fromActionClosure = {[weak self] (action: UIAction) in
            self?.fromSelectionAction = action
            self?.fromButton.setTitle(self?.fromSelectionAction?.title, for: .normal)
            self?.reconfigurePlayList()
        }
        let toActionClosure = {[weak self] (action: UIAction) in
            self?.toSelectedAction = action
            self?.toButton.setTitle(self?.toSelectedAction?.title, for: .normal)
            self?.reconfigurePlayList()
        }
        let repeatActionClosure = {[weak self] (action: UIAction) in
            self?.repeatSelectionAction = action
            self?.repeatButton.setTitle(self?.repeatSelectionAction?.title, for: .normal)
            self?.reconfigurePlayList()
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
