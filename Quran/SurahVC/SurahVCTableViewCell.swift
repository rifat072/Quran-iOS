//
//  SurahVCTableViewCell.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 23/4/23.
//

import UIKit

protocol SurahTableViewCellDelegate: NSObject{
    func playBtnPressed(verseViewModel: VerseViewModel)
}

class SurahVCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerStackView: UIStackView!
    
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    weak var verseModel: VerseViewModel!
    weak var delegate: SurahTableViewCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }
    @IBOutlet weak var translationViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBAction func playBtnPressed(_ sender: Any) {
        self.delegate?.playBtnPressed(verseViewModel: verseModel)
    }
    func removeViews(){
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
    }
    
    func updateAppearanceFor(verseViewModel: VerseViewModel,wordSpacing: CGFloat){
        self.verseModel = verseViewModel
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
        
        let lines = verseViewModel.generateDisplayView(wordSpacing: wordSpacing, lineMaxWidth: self.bounds.width)
        for line in lines {
            containerStackView.addArrangedSubview(line)
        }
        
        let height = verseViewModel.getTranslationViewHeight(width: self.bounds.width - 20)
        self.translationViewHeightConstraint.constant = height + 20
        let translation = verseViewModel.verse.getTranslation(for: SettingsData.shared.translationReciterId)
        
        
        self.translationLabel.text = translation?.text
    }
    
    
}

