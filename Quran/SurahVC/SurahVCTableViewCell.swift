//
//  SurahVCTableViewCell.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 23/4/23.
//

import UIKit

class SurahVCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerStackView: UIStackView!
    
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }

    
    @IBAction func playBtnPressed(_ sender: Any) {
    }
    func removeViews(){
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
    }
    
    func updateAppearanceFor(verseViewModel: VerseViewModel,wordSpacing: CGFloat){
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
        
        let lines = verseViewModel.generateDisplayView(wordSpacing: wordSpacing, lineMaxWidth: self.bounds.width)
        for line in lines {
            containerStackView.addArrangedSubview(line)
        }
        
        let translation = verseViewModel.verse.getTranslation(for: SettingsData.shared.translationReciterId)
        
        self.translationLabel.text = translation?.text
    }
    
    
}
