//
//  SurahCollectionViewCell.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahCollectionViewCell: UICollectionViewCell {

    public static let reuseIdentifier = "SurahCollectionViewCell"
    
    @IBOutlet weak var translationLabel: UILabel!
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var containerStackView: UIStackView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }

    
    func updateAppearanceFor(verseViewModel: VerseViewModel,wordSpacing: CGFloat){
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
        let splitText = verseViewModel.verse.verse_key.split(separator: ":")[1]
        self.titleLbl.text = "Ayah - \(splitText )"
        
        let lines = verseViewModel.generateDisplayView(wordSpacing: wordSpacing, lineMaxWidth: self.bounds.width)
        for line in lines {
            containerStackView.addArrangedSubview(line)
        }
        
        let translation = verseViewModel.verse.getTranslation(for: SettingsData.shared.translationReciterId)
        
        self.translationLabel.text = translation?.text
    }

}
