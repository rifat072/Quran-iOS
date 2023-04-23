//
//  VerseViewModel.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 21/4/23.
//

import UIKit

class VerseViewModel: NSObject {

    let verse: Verse
    let wordViewModels: [WordViewModel]
    
    init(verse: Verse){
        self.verse = verse
        var tempWordModels: [WordViewModel] = []
        if self.verse.words != nil{

            for i in 0..<self.verse.words!.count{
                if self.verse.words![i].char_type_name == "end" {
                    continue
                }
                tempWordModels.append(WordViewModel(word: self.verse.words![i]))
            }
        }
        
        self.wordViewModels = tempWordModels
    }
    
    func getLineCount(maxWidth: CGFloat, itemSpacing: CGFloat = 15) -> Int{
        var currWidth: CFloat = 0
        var lineCount: Int = 1
        
        for wordViewModel in wordViewModels {
            let wordWidth: CGFloat = wordViewModel.getMaxWidth()
            if CGFloat(currWidth) + wordWidth <= maxWidth {
                currWidth += Float(wordWidth + itemSpacing)
            } else {
                lineCount += 1
                currWidth = CFloat(wordWidth + itemSpacing)
            }
        }

        return lineCount
    }
    
    func generateDisplayView(wordSpacing: CGFloat, lineMaxWidth: CGFloat) -> [UIView]{
        
        func generateNewLine() -> UIStackView{
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = wordSpacing
            return stackView
        }
        
        var lines: [UIView] = []
        
        var currentWordCount: CGFloat = 0
        var currentLine: UIStackView? = generateNewLine()
        var currentLineWidth: CGFloat = 0
        
        
        func addToLine(view: UIView, width: CGFloat){
            if(width + currentLineWidth + (wordSpacing * currentWordCount) > lineMaxWidth){
                if let _currentLine = currentLine{
                    lines.append(_currentLine)
                    currentLine = generateNewLine()
                    currentLineWidth = 0
                    currentWordCount = 0
                }
            }
            currentLine?.insertArrangedSubview(view, at: 0)
            currentLineWidth += width
            currentWordCount += 1
        }

        for wordViewModel in wordViewModels {
            let wordDisplay = wordViewModel.generateDisplayView()
            addToLine(view: wordDisplay.view, width: wordDisplay.width)
        }

        if let _currentLine = currentLine{
            lines.append(_currentLine)
        }
        return lines
    }
    
    func getTranslationViewHeight(width: CGFloat) -> CGFloat{
        WordViewModel.DUMMY_LABEL.frame = CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        WordViewModel.DUMMY_LABEL.numberOfLines = 0
        WordViewModel.DUMMY_LABEL.font = UIFont.systemFont(ofSize: 12)
        WordViewModel.DUMMY_LABEL.text = self.verse.getTranslation(for: SettingsData.shared.translationReciterId)?.text
        WordViewModel.DUMMY_LABEL.lineBreakMode = .byWordWrapping
        WordViewModel.DUMMY_LABEL.sizeToFit()
        
        let view = WordViewModel.DUMMY_LABEL
        return WordViewModel.DUMMY_LABEL.frame.size.height
    }
}
