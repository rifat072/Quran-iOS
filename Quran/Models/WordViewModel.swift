//
//  WordViewObject.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 21/4/23.
//

import UIKit

class WordViewModel: NSObject {
    
    private static let DUMMY_LABEL: UILabel = UILabel()
    
    let word: Word
    
    init(word: Word){
        self.word = word
    }
    weak var lastGeneratedView: UIView? = nil
    
    func generateDisplayView() -> (view: UIView, width: CGFloat){
        
        func generateLabel(str: String?) -> UILabel{
            let label = UILabel()
            label.text = str
            label.textColor = .white
            label.textAlignment = .center
            return label
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        let label1 = generateLabel(str: self.word.text_uthmani)
        label1.font = UIFont.systemFont(ofSize: 15)
        stackView.addArrangedSubview(label1)
        
        if SettingsData.shared.shouldShowTransliteration{
            let label2 = generateLabel(str: self.word.transliteration.text)
            label2.font = UIFont.systemFont(ofSize: 11)
            stackView.addArrangedSubview(label2)
        }

        if SettingsData.shared.wordByWordTranslation{
            let label3 = generateLabel(str: self.word.translation.text)
            label3.font = UIFont.systemFont(ofSize: 11)
            stackView.addArrangedSubview(label3)
            
        }

        
        self.lastGeneratedView = stackView
        return (view: stackView, width: self.getMaxWidth())
    }
    
    func getMaxWidth() -> CGFloat{
        return  max(getWidth(for: self.word.text_uthmani, font: UIFont.systemFont(ofSize: 15)).width,
                    SettingsData.shared.shouldShowTransliteration ? getWidth(for: self.word.transliteration.text, font: UIFont.systemFont(ofSize: 11)).width : 0,
                    SettingsData.shared.wordByWordTranslation ?  getWidth(for: self.word.translation.text, font: UIFont.systemFont(ofSize: 11)).width : 0)
    }
    
    func getWidth(for text: String?, font: UIFont) -> CGSize {
        WordViewModel.DUMMY_LABEL.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        WordViewModel.DUMMY_LABEL.numberOfLines = 0
        WordViewModel.DUMMY_LABEL.font = font
        WordViewModel.DUMMY_LABEL.text = text
        WordViewModel.DUMMY_LABEL.sizeToFit()
        return WordViewModel.DUMMY_LABEL.frame.size
    }

}

